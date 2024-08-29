module playcmds

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.threefold.tfrobot
import os

pub fn play_threefold(mut plbook playbook.PlayBook) ! {
	mut config_actions := plbook.find(filter: 'threefold.configure')!

	mnemonics_ := os.getenv_opt('TFGRID_MNEMONIC') or { '' }
	mut ssh_key := os.getenv_opt('SSH_KEY') or { '' }

	tfrobot.configure('play', network: 'main', mnemonics: mnemonics_)!

	mut robot := tfrobot.get('play')!

	if config_actions.len > 1 {
		return error('can only have 1 config action for threefold')
	} else if config_actions.len == 1 {
		mut a := config_actions[0]
		mut p := a.params
		mut network := p.get_default('network', 'main')!
		mnemonics := p.get_default('mnemonics', '')!
		ssh_key = p.get_default('ssh_key', '')!

		network = network.to_lower()

		// mnemonics  string
		// network    string = 'main'					
		tfrobot.configure('play', network: network, mnemonics: mnemonics)!

		robot = tfrobot.get('play')!

		config_actions[0].done = true
	}
	cfg := robot.config()!
	if cfg.mnemonics == '' {
		return error('TFGRID_MNEMONIC should be specified as env variable')
	}

	if ssh_key == '' {
		return error('SSHKey should be specified as env variable')
	}

	panic('implement')

	// for mut action in plbook.find(filter: 'threefold.deploy_vm')! {
	// 	mut p := action.params
	// 	deployment_name := p.get_default('deployment_name', 'deployment')!
	// 	name := p.get_default('name', 'vm')!
	// 	ssh_key := p.get_default('ssh_key', '')!
	// 	cores := p.get_int_default('cores', 1)!
	// 	memory := p.get_int_default('memory', 20)!
	// 	panic("implement")
	// 	action.done = true
	// }

	// for mut action in plbook.find(filter: 'threefold.deploy_zdb')! {
	// 	panic("implement")
	// 	action.done = true
	// }
}
