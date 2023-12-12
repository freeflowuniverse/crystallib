module sshagent

import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct KeyGetArgs {
pub mut:
	pubkey string
	// privkey string	
	// privkey_path string
	name string
}

pub fn (mut agent SSHAgent) get(args_ KeyGetArgs) ?SSHKey {
	mut args := args_
	args.pubkey = args.pubkey.trim_space()
	args.name = texttools.name_fix(args.name)
	for mut key in agent.keys {
		mut found := false
		if args.name.len > 0 && key.name == args.name {
			found = true
		}
		if args.pubkey.len > 0 && key.pubkey == args.pubkey {
			found = true
		}
		if found {
			return key
		}
	}
	return none
}

fn (mut agent SSHAgent) pop(pubkey_ string) {
	mut x := 0
	mut result := 9999
	for key in agent.keys {
		if key.pubkey == pubkey_ {
			result = x
			break
		}
		x += 1
	}
	if result != 9999 {
		if agent.keys.len > result {
			agent.keys.delete(x)
		} else {
			panic('bug')
		}
	}
}

pub fn (mut agent SSHAgent) exists(args KeyGetArgs) bool {
	agent.get(args) or { return false }
	return true
}
