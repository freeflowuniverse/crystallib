module playcmds

import freeflowuniverse.crystallib.osal.sshagent
import freeflowuniverse.crystallib.core.playbook

pub fn play_ssh(mut plbook playbook.PlayBook) ! {
	mut agent := sshagent.new()!
	for mut action in plbook.find(filter: 'sshagent.*')! {
		mut p := action.params
		match action.name {
			'key_add' {
				name := p.get('name')!
				privkey := p.get('privkey')!
				agent.add(name, privkey)!
			}
			else {
				return error('action name ${action.name} not supported')
			}
		}
		action.done = true
	}
}
