module sshagent

// import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.pathlib

@[heap]
pub struct SSHAgent {
pub mut:
	keys     []SSHKey
	active   bool
	homepath pathlib.Path
}

// get all keys from sshagent and from the local .ssh dir
pub fn (mut agent SSHAgent) init() ! {
	// first get keys out of ssh-add	
	agent.keys = []SSHKey{}
	res := os.execute('ssh-add -L')
	if res.exit_code == 0 {
		for line in res.output.split('\n') {
			if line.trim(' ') == '' {
				continue
			}
			if line.contains(' ') {
				splitted := line.split(' ')
				if splitted.len < 2 {
					panic('bug')
				}
				pubkey := splitted[1]
				mut sshkey := SSHKey{
					pubkey: pubkey
					agent: &agent
					loaded: true
				}
				if splitted[0].contains('ed25519') {
					sshkey.cat = .ed25519
					if splitted.len > 2 {
						sshkey.email = splitted[2] or { panic('bug') }
					}
				} else if splitted[0].contains('rsa') {
					sshkey.cat = .rsa
				} else {
					panic('bug: implement other cat for ssh-key')
				}

				if !(agent.exists(pubkey: pubkey)) {
					// println("add $sshkey")
					agent.keys << sshkey
				}
			}
		}
	}

	// now get them from the filesystem
	mut fl := agent.homepath.list()!
	mut sshfiles := fl.paths.clone()
	mut pubkeypaths := sshfiles.filter(it.path.ends_with('.pub'))
	for mut pkp in pubkeypaths {
		mut c := pkp.read()!
		c = c.replace('  ', ' ').replace('  ', ' ') // deal with double spaces, or tripple (need to do this 2x
		splitted := c.trim_space().split(' ')
		if splitted.len < 2 {
			panic('bug')
		}
		mut name := pkp.name()
		name = name[0..(name.len - 4)]
		pubkey2 := splitted[1]
		// the pop makes sure the key is removed from keys in agent, this means we can add later
		mut sshkey2 := agent.get(pubkey: pubkey2) or {
			SSHKey{
				name: name
				pubkey: pubkey2
				agent: &agent
			}
		}
		agent.pop(sshkey2.pubkey)
		sshkey2.name = name
		if splitted[0].contains('ed25519') {
			sshkey2.cat = .ed25519
		} else if splitted[0].contains('rsa') {
			sshkey2.cat = .rsa
		} else {
			panic('bug: implement other cat for ssh-key')
		}
		if splitted.len > 2 {
			sshkey2.email = splitted[2]
		}
		agent.keys << sshkey2
	}
}

// returns path to sshkey
pub fn (mut agent SSHAgent) generate(name string, passphrase string) !SSHKey {
	dest := '${agent.homepath.path}/${name}'
	if os.exists(dest) {
		os.rm(dest)!
	}
	cmd := 'ssh-keygen -t ed25519 -f ${dest} -P ${passphrase} -q'
	// println(cmd)
	rc := os.execute(cmd)
	if !(rc.exit_code == 0) {
		return error('Could not generated sshkey,\n${rc}')
	}
	agent.init()!
	return agent.get(name: name) or { panic(err) }
}

// unload all ssh keys
pub fn (mut agent SSHAgent) reset() ! {
	res := os.execute('ssh-add -D')
	if res.exit_code > 0 {
		return error('cannot reset sshkeys.')
	}
	agent.init()! // should now be empty for loaded keys
}

// load the key, they key is content (private key) .
// a name is required
pub fn (mut agent SSHAgent) add(name string, privkey string) !SSHKey {
	agent.reset()!
	path := '${agent.homepath.path}/${name}'
	if os.exists(path) {
		os.rm(path)!
	}
	os.write_file(path, privkey)!
	return agent.load(path)!
}

// load key starting from path to private key
pub fn (mut agent SSHAgent) load(keypath string) !SSHKey {
	if !os.exists(keypath) {
		return error('cannot find sshkey: ${keypath}')
	}
	if keypath.ends_with('.pub') {
		return error('can only load private keys')
	}
	name := keypath.split('.').last()
	res := os.execute('ssh-add ${keypath}')
	if res.exit_code > 0 {
		return error('cannot add ssh-key with path ${keypath}')
	}
	agent.init()!
	return agent.get(name: name) or { panic(err) }
}

// forget the specified key
pub fn (mut agent SSHAgent) forget(name string) ! {
	mut key := agent.get(name: name) or { return }
	agent.pop(key.pubkey)
	key.forget()!
}

pub fn (mut agent SSHAgent) str() string {
	mut out := []string{}
	out << '\n## SSHAGENT:\n'
	for mut key in agent.keys {
		out << key.str()
	}
	return out.join_lines() + '\n'
}