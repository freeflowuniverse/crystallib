module play

import freeflowuniverse.crystallib.osal.sshagent

pub fn (mut session Session) play_ssh() ! {

	mut agent := sshagent.new()!
	for mut action in session.plbook.find(filter: 'sshagent.*')! {
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
