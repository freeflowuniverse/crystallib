module gittools

import os


pub fn (addr GitAddr) url_get() string {
	if ssh_agent_loaded() {
		return addr.url_ssh_get()
	} else {
		return addr.url_http_get()
	}
}

pub fn (addr GitAddr) url_ssh_get() string {
	return 'git@$addr.provider:$addr.account/${addr.name}.git'
}

pub fn (addr GitAddr) url_http_get() string {
	return 'https://$addr.provider/$addr.account/$addr.name'
}

// return http url with branch inside
fn (addr GitAddr) url_http_with_branch_get() string {
	u := addr.url_http_get()
	if addr.branch != '' {
		return '$u/tree/$addr.branch'
	} else {
		return u
	}
}

// return provider e.g. github, account is the name of the account, name of the repo, path if any
// deals with quite some different formats Returns
// ```
// struct GitAddr{
// 	mut:
// 		provider string
// 		account string
// 		name string
// 		path string		//path in the repo
// 		branch string
// 		anker string //position in the file
// }
// ```
pub fn addr_get_from_url(url string) ?GitAddr {
	mut urllower := url.to_lower()
	urllower = urllower.trim_space()
	if urllower.starts_with('git@') {
		urllower = urllower[4..]
	}
	if urllower.starts_with('http:/') {
		urllower = urllower[6..]
	}
	if urllower.starts_with('https:/') {
		urllower = urllower[7..]
	}
	if urllower.ends_with('.git') {
		urllower = urllower[0..urllower.len - 4]
	}
	urllower = urllower.replace(':', '/')
	urllower = urllower.replace('//', '/')
	urllower = urllower.trim('/')
	urllower = urllower.replace('/blob/', '/')
	urllower = urllower.replace('/tree/', '/')
	// println("AA:$urllower")
	mut parts := urllower.split('/')
	mut anker := ''
	mut path := ''
	mut branch := ''
	// deal with path
	if parts.len > 4 {
		path = parts[4..parts.len].join('/')
		if path.contains('#') {
			parts2 := path.split('#')
			if parts2.len == 2 {
				path = parts2[0]
				anker = parts2[1]
			} else {
				return error("url badly formatted have more than 1 x '#' in $url")
			}
		}
	}
	// found the branch
	if parts.len > 3 {
		branch = parts[3]
		parts[2] = parts[2].replace('.git', '')
	}
	if parts.len < 3 {
		return error("url badly formatted, not enough parts in '$urllower' \nparts:\n$parts")
	}

	provider := parts[0]
	account := parts[1]
	name := parts[2]
	return GitAddr{
		provider: provider
		account: account
		name: name
		branch: branch
		anker: anker
		path: path
	}
}

// returns the git arguments starting from a git path
// ```
// struct GitAddr{
// 	mut:
// 		provider string
// 		account string
// 		name string
// 		path string		//path in the repo
// 		branch string
// 		anker string //position in the file
// }
// ```
pub fn addr_get_from_path(path string) ?GitAddr {
	// TODO: need to get it to work for branch

	
	mut path2 := path.replace('~', os.home_dir())
	if !os.exists(os.join_path(path2, '.git')) {
		return error("path: '$path2' is not a git dir, missed a .git directory")
	}
	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '$path2' is not a git dir, missed a .git/config file")
	}

	cmd := "cd $path && git config --get remote.origin.url"
	url := os.execute_or_panic(cmd).output.trim(" \n")

	cmd2 := "cd $path && git rev-parse --abbrev-ref HEAD"
	branch := os.execute_or_panic(cmd2).output.trim(" \n")
	
	///////the parsing was not good enough

	// content := os.read_file(pathconfig) or { panic('Failed to load config $pathconfig') }
	// mut state := 'start'
	// mut line2 := ''
	// mut url := ''
	// mut branch := ''
	// for line in content.split_into_lines() {
	// 	line2 = line.trim_space()
	// 	// println(" - '$line2'")
	// 	if state == 'start' && line.starts_with('[remote') {
	// 		state = 'remote'
	// 		continue
	// 	}
	// 	if state == 'remote' && line.starts_with('[') {
	// 		state == 'start'
	// 	}
	// 	if state == 'remote' && line2.starts_with('url') {
	// 		url = line2.split('=')[1]
	// 		state = 'branch'
	// 	}
	// 	if state == 'branch' && line2.starts_with('merge') {
	// 		parts := line2.split('/')
	// 		branch = parts[parts.len - 1]
	// 		state = 'end'
	// 	}
	// }
	// if url == '' {
	// 	return error('could not parse config file to find url for git.\n$content')
	// }

	// println(content)
	// println("UUUUU URL:$url")

	// TODO: NOT GOOD NEED TO DO BETTER

	// add branch
	// mut splitted := path.split('/')
	// if branch == '' {
	// 	// branch = splitted[splitted.len]
	// 	panic('bug branch not there yet')
	// }
	// url = '$url/$branch'
	mut addr := addr_get_from_url(url) ?
	addr.branch = branch
	// println(addr)
	return addr
}
