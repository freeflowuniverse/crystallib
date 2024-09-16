module ufw

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os

pub fn reset() ! {
	osal.execute_silent('
		ufw --force disable
		ufw --force reset
		ufw allow 22
		ufw --force enable
		')!
	console.print_debug('UFW Reset')
}

// ufw allow proto tcp to any port 80

pub fn apply_rule(rule_ Rule) ! {
	mut rule := rule_
	mut command := 'ufw '

	if rule.allow {
		command += 'allow '
	} else {
		command += 'deny '
	}

	if rule.tcp && !rule.udp {
		command += 'proto tcp '
	} else if !rule.tcp && rule.udp {
		command += 'proto udp '
	}

	if rule.from.trim_space() == '' {
		rule.from = 'any'
	}

	if rule.from != 'any' {
		command += 'from ${rule.from} '
	}

	command += 'to any '

	if rule.port == 0 {
		return error('rule port cannot be 0, needs to be a port nr')
	}

	command += 'port ${rule.port} '

	result := os.execute(command)
	if result.exit_code != 0 {
		return error('Failed to apply rule: \n${rule}\n${command}\nError: ${result.output}')
	}
	console.print_debug('Rule applied: ${command}')
}

pub fn allow_ssh() ! {
	osal.execute_silent('ufw default deny incoming')! // make sure all is default denied
	osal.execute_silent('ufw allow ssh')!
}

pub fn disable() ! {
	osal.execute_silent('ufw --force disable')!
}

pub fn enable() ! {
	allow_ssh()!
	osal.execute_silent('ufw --force enable')!
}

pub fn apply(ruleset RuleSet) ! {
	if ruleset.reset {
		reset()!
	}
	disable()!
	console.print_debug('UFW Disabled')
	for rule in ruleset.rules {
		apply_rule(rule)!
	}
	if ruleset.ssh {
		console.print_debug('SSH enable')
		allow_ssh()!
	}
	enable()!
	console.print_debug('UFW Enabled and Configured')
}

pub fn new() RuleSet {
	return RuleSet{}
}
