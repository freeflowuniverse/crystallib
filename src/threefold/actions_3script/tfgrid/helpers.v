module tfgrid

import freeflowuniverse.crystallib.baobab.actions { Action }

pub fn (mut t TFGridHandler) helper(action Action) ! {
	match action.actor {
		'sshkeys' {
			t.ssh_key_helper(action)!
		}
		else {
			return error('helper action ${action.actor} is invalid')
		}
	}
}

fn (mut t TFGridHandler) ssh_key_helper(action Action) ! {
	match action.name {
		'new' {
			name := action.params.get('name')!
			key := action.params.get('ssh_key')!
			t.ssh_keys[name] = key
		}
		else {
			return error('helper action name ${action.name} is invalid')
		}
	}
}

fn (mut t TFGridHandler) get_ssh_key(name string) !string {
	return t.ssh_keys[name] or { return error('ssh key ${name} does not exist') }
}
