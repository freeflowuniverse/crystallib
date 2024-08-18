module ufw

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os


pub fn reset() ! {
	console.print_debug('reset ufw')
	osal.execute_silent("
		ufw --force disable
		ufw --force reset
		ufw allow 22
		ufw --force enable
		")!
}




pub fn apply_rule(rule_ Rule) ! {
	mut rule := rule_
	mut command := 'ufw '
	
	if rule.allow {
		command += 'allow '
	} else {
		command += 'deny '
	}

	if rule.from.trim_space()==""{
		rule.from = 'any'
	}

	if rule.from != 'any' {
		command += 'from ${rule.from} '
	}

	if rule.to.trim_space()==""{
		rule.to = 'any'
	}

	if rule.to != 'any' {
		command += 'to ${rule.to} '
	}

	if rule.tcp && !rule.udp {
		command += 'proto tcp '
	} else if !rule.tcp && rule.udp {
		command += 'proto udp '
	}
	// result := os.execute(command)
	// if result.exit_code != 0 {
	// 	return error('Failed to apply rule: ${command}\nError: ${result.output}')
	// }
	println('Rule applied: ${command}')
}

fn allow_ssh(){
	os.execute_or_panic('ufw allow ssh')
}

fn disable_ufw() {
	os.execute_or_panic('ufw --force enable')
}


fn enable_ufw() {
	os.execute_or_panic('ufw --force disable')
}


pub fn apply(ruleset RuleSet) ! {
	if ruleset.reset {
		reset()!
	}
	disable_ufw()
	for rule in ruleset.rules {
		apply_rule(rule)!
	}
	if ruleset.ssh {
		allow_ssh() 
	}	
	enable_ufw()
}

pub fn new() RuleSet{
	return RuleSet{}
}