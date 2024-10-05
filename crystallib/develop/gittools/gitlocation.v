module gittools
import freeflowuniverse.crystallib.core.pathlib

// unique identification of a git repository
// can be translated to location on filesystem
// can be translated to url of the git repository online
@[heap]
pub struct GitLocation {
pub mut:
	provider   string
	account    string
	name       string // is the name of the repository
	branch     string
	tag 	   string
	path  string // path in the repo (not on filesystem)
	anker string // position in the file
}


// Get GitLocation from path within the Git repository
pub fn (mut gs GitStructure) gitlocation_from_path(path string) !GitLocation {

	mut full_path := pathlib.get(path)
	rel_path := full_path.path_relative(gs.coderoot.path)!

	mut parts := rel_path.split('/')
	if parts.len < 3 {
		return error("git: path is not valid, should contain provider/account/repository: '${rel_path}'")
	}

	provider := parts[0]
	account := parts[1]
	name := parts[2]
	mut repo_path := ''

	if parts.len > 3 {
		repo_path = parts[3..].join('/')
	}

	mut gl := GitLocation{
		provider: provider
		account: account
		name: name
		path: repo_path
	}

	return gl
}

// will use url to get git locator (is a pointer to a file, dir or part of file)
pub fn (mut gs GitStructure) gitlocation_from_url(url string) !GitLocation {
	mut urllower := url.to_lower().trim_space()
	if urllower == '' {
		return error('url cannot be empty')
	}

	// Normalize URL
	if urllower.starts_with('ssh://') {
		urllower = urllower[6..]
	}
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
	urllower = urllower.replace(':', '/').replace('//', '/').trim('/')
	urllower = urllower.replace('/blob/', '/').replace('/src/branch/', '/tree/').replace('/tree/', '/')

	mut parts := urllower.split('/')
	mut anker := ''
	mut path := ''
	mut branch := ''

	// Deal with path and anchor
	if parts.len > 4 {
		path = parts[4..].join('/')
		if path.contains('#') {
			parts2 := path.split('#')
			if parts2.len == 2 {
				path = parts2[0]
				anker = parts2[1]
			} else {
				return error("git: url badly formatted, more than 1 '#' in ${url}")
			}
		}
	}

	// Found the branch
	if parts.len > 3 {
		branch = parts[3]
		parts[2] = parts[2].replace('.git', '')
	}

	if parts.len < 3 {
		return error("git: url badly formatted, not enough parts in '${urllower}' \nparts:\n${parts}")
	}

	provider := parts[0]
	account := parts[1]
	name := parts[2]

	mut gl := GitLocation{
		provider: if provider == 'github.com' { 'github' } else { provider }
		account: account
		name: name
		branch: branch
		path: path
		anker: anker
	}

	return gl
}

// return a crystallib path object on the filesystem pointing to the locator
pub fn (mut l GitLocation) patho() !pathlib.Path {
	mut addrpath := pathlib.get_dir(path:'${l.provider}/${l.account}/${l.name}',create:false)!
	if l.path.len > 0 {
		return pathlib.get('${addrpath.path}/${l.path}')
	}
	return addrpath
}