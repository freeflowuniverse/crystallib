module sshagent
import os
import freeflowuniverse.crystallib.core.pathlib

@[heap]
pub struct SSHKey {
pub mut:
	name   string
	pubkey string
	loaded bool
	email  string
	agent  &SSHAgent @[skip; str: skip]
	cat    SSHKeyCat
}

pub enum SSHKeyCat {
	ed25519
	rsa
}

pub fn (mut key SSHKey) keypath() !pathlib.Path {
	if key.name.len == 0 {
		return error('cannot have key name empty to get path.')
	}
	return key.agent.homepath.file_get_new('${key.name}')!
}

pub fn (mut key SSHKey) keypath_pub() !pathlib.Path {
	if key.name.len == 0 {
		return error('cannot have key name empty to get path.')
	}
	mut p := key.agent.homepath.file_get_new('${key.name}.pub')!
	if !(os.exists('${key.agent.homepath.path}/${key.name}.pub')) {
		p.write(key.pubkey)!
	}
	return p
}

// load the key, they key is content, other keys will be unloaded
pub fn (mut key SSHKey) forget() ! {
	if key.loaded == false {
		return
	}
	mut keypath := key.keypath_pub() or {
		return error('keypath not set or known on sshkey: ${key}')
	}
	if !os.exists(keypath.path) {
		return error('cannot find sshkey: ${keypath}')
	}
	res := os.execute('ssh-add -d ${keypath.path}')
	if res.exit_code > 0 {
		return error('cannot forget ssh-key with path ${keypath.path}')
	}
	key.agent.init()!
}

pub fn (mut key SSHKey) str() string {
	patho := key.keypath_pub() or { pathlib.Path{} }
	mut l := ' '
	if key.loaded {
		l = 'L'
	}
	return '${key.name:-15} : ${l} : ${key.cat:-8} :  ${key.email:-25} : ${patho.path}'
}

pub fn (mut key SSHKey) load() ! {
	$if debug {
		println(" - sshkey load: '${key}'")
	}
	if key.name.len == 0 {
		return error('can only load keys which are on filesystem and as such have a name.')
	}
	patho := key.keypath() or {
		return error('cannot load because privkey not on fs.\n${err}\n${key}')
	}
	res := os.execute('ssh-add ${patho.path}')
	if res.exit_code > 0 {
		return error('cannot add ssh-key with path ${patho.path}.\n${res}')
	}
	key.agent.init()!
}
