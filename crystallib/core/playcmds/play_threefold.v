module playcmds

import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.threefold.tfrobot
import os

pub fn play_threefold(mut plbook playbook.PlayBook) ! {
	mut coderoot := ''
	mut reset := false
	mut pull := false

	mut config_actions := plbook.find(filter: 'threefold.configure')!

	// TFRobot for multiple deployments, deployer for singular
	mut robot := tfrobot.TFRobot{}
	mut deployer := grid.Deployer{}

	if config_actions.len > 1 {
		return error('can only have 1 config action for threefold')
	} else if config_actions.len == 1 {
		network := p.get_default('network', 'main')
		mneumonics := p.get_default('mneumonics', '')!
		ssh_key := p.get_default('ssh_key', '')!
		
		robot = tfrobot.configure(
			network: .main
			mneumonics: mneumonics
			ssh_key: ssh_key
		)!
		config_actions[0].done = true
	}

	for mut action in plbook.find(filter: 'threefold.deploy_vm')! {
		deployment_name := p.get_default('deployment_name', 'deployment')
		name := p.get_default('name', 'vm')!
		ssh_key := p.get_default('ssh_key', '')!
		cores := p.get_int_default('cores', 1)!
		memory := p.get_int_default('memory', 20)!
		j.start()!
		action.done = true
	}

	for mut action in plbook.find(filter: 'threefold.deploy_zdb')! {
		j.restart()!
		action.done = true
	}
}
