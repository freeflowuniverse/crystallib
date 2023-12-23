module play

import freeflowuniverse.crystallib.osal.sshagent

pub fn play(args PlayArgs) ! {
	mut session:=session_new(args)!
	mut agent := sshagent.new()!
	for action in session.actions.find(actor: 'sshagent')! {
		mut p:=action.params
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
	}
}
	
