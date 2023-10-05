module gittools

import os
import freeflowuniverse.crystallib.sshagent
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.pathlib

// unique identification of a git repository
// can be translated to location on filesystem
// can be translated to url of the git repository online
pub struct GitAddr {
	gs &GitStructure
pub mut:
	// root string
	provider string
	account  string
	name     string // is the name of the repository
	branch   string
}

// internal function to check git address
fn (mut addr GitAddr) check() ! {
	if addr.provider == 'github.com' {
		addr.provider = 'github'
	}
}


// return the path on the filesystem pointing to the address (is always a dir)
pub fn (addr GitAddr) path() !pathlib.Path {
	provider := texttools.name_fix(addr.provider)
	name := texttools.name_fix(addr.name)
	account := texttools.name_fix(addr.account)
	mut path_string := '${addr.gs.rootpath}/${provider}/${account}/${name}'
	if addr.gs.rootpath.path == '' {
		panic('cannot be empty')
	}
	if addr.gs.config.multibranch {
		path_string += '/${addr.branch}'
	}
	path := pathlib.get_dir(path_string, true)!
	return path
}

fn (mut addr GitAddr) path_account() pathlib.Path {
	mut provider := ''
	// addr := repo.addr
	if addr.gs.rootpath.path == '' {
		panic('cannot be empty')
	}
	path := pathlib.get_dir('${addr.gs.rootpath}/${provider}/${addr.account}', true) or {
		panic('couldnt get directory')
	}
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
	return 'git@${addr.provider}:${addr.account}/${addr.name}.git'
}

pub fn (addr GitAddr) url_http_get() string {
	return 'https://${addr.provider}/${addr.account}/${addr.name}'
}

// return http url with branch inside
fn (addr GitAddr) url_http_with_branch_get() string {
	u := addr.url_http_get()
	if addr.branch != '' {
		return '${u}/tree/${addr.branch}'
	} else {
		return u
	}
}

pub fn (addr GitAddr) str() string {
	if addr.branch == '' {
		panic('bug, addr branch should never be empty')
	}
	return '${addr.provider}:${addr.account}/${addr.name}[${addr.branch}]'
}
