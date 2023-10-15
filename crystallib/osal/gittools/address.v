module gittools

import freeflowuniverse.crystallib.tools.sshagent
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib

// unique identification of a git repository
// can be translated to location on filesystem
// can be translated to url of the git repository online
pub struct GitAddr {
	gs &GitStructure [skip; str: skip]
pub mut:
	// root string
	provider     string
	account      string
	name         string // is the name of the repository
	branch       string
	url_original string
}

// internal function to check git address
fn (addr GitAddr) check() {
	if addr.provider == '' || addr.account == '' || addr.name == '' {
		panic('provider, account or name is empty: ${addr.provider}/${addr.account}/${addr.name}')
	}
}

// return the path on the filesystem pointing to the address (is always a dir)
pub fn (addr GitAddr) path() !pathlib.Path {
	addr.check()
	provider := texttools.name_fix(addr.provider)
	name := texttools.name_fix(addr.name)
	account := texttools.name_fix(addr.account)
	mut path_string := '${addr.gs.rootpath.path}/${provider}/${account}/${name}'
	if addr.gs.rootpath.path == '' {
		panic('roorpath cannot be empty')
	}
	if addr.gs.config.multibranch {
		path_string += '/${addr.branch}'
	}
	path := pathlib.get_dir(path_string, false)!
	return path
}

fn (addr GitAddr) path_account() pathlib.Path {
	addr.check()
	if addr.gs.rootpath.path == '' {
		panic('cannot be empty')
	}
	path := pathlib.get_dir('${addr.gs.rootpath.path}/${addr.provider}/${addr.account}',
		true) or { panic('couldnt get directory') }
	return path
}

// url_get returns the url of a git address
pub fn (addr GitAddr) url_get() string {
	if sshagent.loaded() {
		return addr.url_ssh_get()
	} else {
		return addr.url_http_get()
	}
}

pub fn (addr GitAddr) url_ssh_get() string {
	addr.check()
	mut provider := addr.provider
	if provider == 'github' {
		provider = 'github.com'
	}
	return 'git@${provider}:${addr.account}/${addr.name}.git'
}

pub fn (addr GitAddr) url_http_get() string {
	addr.check()
	mut provider := addr.provider
	if provider == 'github' {
		provider = 'github.com'
	}
	return 'https://${provider}/${addr.account}/${addr.name}'
}

// return http url with branch inside
fn (addr GitAddr) url_http_with_branch_get() string {
	addr.check()
	u := addr.url_http_get()
	if addr.branch != '' {
		return '${u}/tree/${addr.branch}'
	} else {
		return u
	}
}

pub fn (addr GitAddr) str() string {
	addr.check()
	if addr.branch == '' {
		panic('bug, addr branch should never be empty')
	}
	return '${addr.provider}:${addr.account}/${addr.name}[${addr.branch}]'
}

fn (addr GitAddr) cachekey() string {
	addr.check()
	return '${addr.provider}__${addr.account}__${addr.name}'
}
