module gittools

import os

struct GitAddr {
	root string
pub mut:
	provider string
	account  string
	name     string // is the name of the repository
	path     string // path in the repo (not on filesystem)
	branch   string
	anker    string // position in the file
}


fn (addr GitAddr) path_get() string {
	mut provider := ''
	if addr.provider == 'github.com' {
		provider = 'github'
	} else {
		provider = addr.provider
	}
	if addr.root == '' {
		panic('cannot be empty')
	}
	return '$addr.root/$provider/$addr.account/$addr.name/$addr.branch'
}

fn (addr GitAddr) path_account_get() string {
	mut provider := ''
	if addr.provider == 'github.com' {
		provider = 'github'
	} else {
		provider = addr.provider
	}
	if addr.root == '' {
		panic('cannot be empty')
	}
	return '$addr.root/$provider/$addr.account'
}

fn (addr GitAddr) url_get() string {
	if ssh_agent_loaded() {
		return addr.url_ssh_get()
	} else {
		return addr.url_http_get()
	}
}

fn (addr GitAddr) url_ssh_get() string {
	return 'git@$addr.provider:$addr.account/${addr.name}.git'
}

fn (addr GitAddr) url_http_get() string {
	return 'https://$addr.provider/$addr.account/$addr.name'
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
pub fn (gs GitStructure) addr_get_from_url(url string) ?GitAddr {
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
	// println("AA:$urllower")
	parts := urllower.split('/')
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
	}
	if parts.len < 3 {
		return error('url badly formatted, not enough parts in $urllower')
	}

	provider := parts[0]
	account := parts[1]
	name := parts[2]
	return GitAddr{
		root: gs.root
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
pub fn (gs GitStructure) addr_get_from_path(path string) ?GitAddr {
	//"cd #{@path} && git config --get remote.origin.url"
	mut path2 := path.replace('~', os.home_dir())
	path_git := path_parent(path2, '.git')?
	// if !os.exists(os.join_path(path2, '.git')) {
	// 	return error("path: '$path2' is not a git dir, missed a .git directory")
	// }
	path_post := 
	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '$path2' is not a git dir, missed a .git/config file")
	}
	content := os.read_file(pathconfig) or { panic('Failed to load config $pathconfig') }
	mut state := 'start'
	mut line2 := ''
	mut url := ''
	mut branch := ''
	for line in content.split_into_lines() {
		line2 = line.trim_space()
		println(" - GITCONFIGLINE: '$line2'")
		if line.starts_with('[') {
			line2 = line[1..] //remove first char
			line2 = line2.split("]")[0] //get in between []
			if " " in line2{
				state = line2.split(" ")[0]
			}else{
				state = line2
			}
			println(" - STATE: $state")

			if "\"" in line2{
				arg := line2.split("\"")[1]
			}else{
				arg := ""
			}
			if state == 'branch' {
				if arg == ""{
					return error("cannot find branch name on line $line")
				}
				branch = arg
			}		
			continue
		}
		if state == 'remote' && line2.starts_with('url') {
			url = line2.split('=')[1].trim(" ")
		}
	}
	if url == '' {
		return error('could not parse config file to find url for git.\n$content')
	}
	mut addr := gs.addr_get_from_url(url)
	//now need to get the branch
	addr.branch = branch
	return addr

}

