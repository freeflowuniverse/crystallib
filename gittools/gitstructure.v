module gittools

import freeflowuniverse.crystallib.pathlib { Path }
import os
import freeflowuniverse.crystallib.texttools

[params]
pub struct RepoGetFromUrlArgs {
pub mut:
	url    string
	branch string
	pull   bool // will pull if this is set
	reset  bool // this means will pull and reset all changes
	name   string
}

// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
// struct RepoGetFromUrlArgs {
// 	url    string
// 	branch string
// 	pull   bool // will pull if this is set
// 	reset bool //this means will pull and reset all changes
// }
pub fn (mut gitstructure GitStructure) repo_get_from_url(args RepoGetFromUrlArgs) !&GitRepo {
	mut addr := addr_get_from_url(args.url) or { return error('cannot get addr from url:${err}') }

	if addr.branch != '' && args.branch != '' && addr.branch != args.branch {
		return error('conflict in branch names.\naddr:\n${addr}\nargs:\n${args}')
	}
	if addr.branch == '' {
		addr.branch = args.branch
	}
	return gitstructure.repo_get_from_addr(addr, args)
}

// get gitrepo from gitaddress struct
// struct RepoGetFromUrlArgs {
// 	url    string
// 	branch string
// 	pull   bool // will pull if this is set
// 	reset bool //this means will pull and reset all changes
//	name   string
// }
// pub struct GitAddr {
// 	provider string
// 	account  string
// 	name     string // is the name of the repository
// 	path     string // path in the repo (not on filesystem)
// 	branch   string
// 	anker    string // position in the file
// 	depth    int    // 0 means we have all depth
// }
pub fn (mut gitstructure GitStructure) repo_get_from_addr(addr GitAddr, args RepoGetFromUrlArgs) !&GitRepo {
	args2 := RepoGetArgs{
		name: addr.name
		account: addr.account
	}
	if !gitstructure.repo_exists(args2) {
		// repo does not exist yet
		println(' - repo does not exist yet')
		gitstructure.repos << GitRepo{
			addr: addr
			id: gitstructure.repos.len
			gs: &gitstructure
			name: args.name
		}
		mut r0 := gitstructure.repo_get(args2) or {
			// means could not pull need to remove the repo from the list again
			gitstructure.repos.delete_last()
			return error('Could not find repo ${args2.account}.${args2.name} \nError:${err}')
		}
		// println (" GIT REPO GET URL: PULL:$args.pull, RESET: $args.reset\n$r0.addr")
		r0.check(args.pull, args.reset)!
		return r0
	} else {
		mut r := gitstructure.repo_get(args2) or {
			return error('cannot load git ${args.url}\n${err}')
		}
		r.addr = addr
		// println (" GIT REPO GET PULL:$args.pull, RESET: $args.reset")
		r.check(args.pull, args.reset)!
		return r
	}
}

// will return repo starting from a path
// if .git not in the path will go for parent untill .git found
// TODO: maybe refactor to implement fn like repo_get_from_url
pub fn (mut gitstructure GitStructure) repo_get_from_path(name string, path Path, pull bool, reset bool) !&GitRepo {
	path2 := path.parent_find('.git')!

	mut addr := addr_get_from_path(path2.path) or {
		return error('cannot get addr from path:${err}')
	}
	// println(" - pull:$pull reset:$reset")
	args := RepoGetFromUrlArgs{
		pull: pull
		reset: reset
		name: name
	}
	// println(addr)
	return gitstructure.repo_get_from_addr(addr, args)
}

pub struct RepoGetArgs {
mut:
	account string
	name    string // is the name of the repository
}

// will return first found git repo
// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
// struct RepoGetArgs {
// 	account string
// 	name    string // is the name of the repository
// 	pull    bool   // will pull if this is set, but not reset
// 	reset bool //this means will pull and reset all changes
// }
// THIS FUNCTION DOES NOT EXECUTE THE CHECK !!!
pub fn (mut gitstructure GitStructure) repo_get(args RepoGetArgs) !&GitRepo {
	mut res_ids := []int{}
	for r in gitstructure.repos {
		if r.name != '' && r.name == args.name {
			res_ids << r.id
			continue
		}
		if r.addr.name == args.name {
			if args.account == '' || args.account == r.addr.account {
				res_ids << r.id
			}
		}
	}
	if res_ids.len == 1 {
		return &gitstructure.repos[res_ids[0]]
	}
	if res_ids.len > 1 {
		for idd in res_ids {
			println(' --- duplicate: ' + gitstructure.repos[idd].path)
		}
		return error("Found too many repo's for account:'${args.account}' name:'${args.name}'")
	}
	// print_backtrace()
	return error("Could not find repo for account:'${args.account}' name:'${args.name}'")
}

// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_exists(addr RepoGetArgs) bool {
	for r in gitstructure.repos {
		if r.name != '' && r.name == addr.name {
			return true
		}
		if r.addr.name == addr.name {
			if addr.account == '' || addr.account == r.addr.account {
				return true
			}
		}
	}
	return false
}

fn (mut gitstructure GitStructure) check() ! {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}
	gitstructure.load()!
}

[params]
pub struct GSArgs {
pub mut:
	filter  string // if used will only show the repo's which have the filter string inside
	pull    bool   // means when getting new repo will pull even when repo is already tehre
	force   bool   // means we will force a pull and reset old content	
	message string // if we want to do a default commit with a message	
	// show    bool	
}

// get a list of repo's which are in line to the args
//
// struct GSArgs {
// 	filter  string		//if used will only show the repo's which have the filter string inside
// 	pull    bool		// means when getting new repo will pull even when repo is already tehre
// 	force   bool		// means we will force a pull and reset old content	
//
pub fn (mut gitstructure GitStructure) repos_get(args GSArgs) []GitRepo {
	mut res := []GitRepo{}
	for mut g in gitstructure.repos {
		relpath := g.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("$g.addr.name")
				res << g
			}
		} else {
			res << g
		}
	}

	return res
}

// print the repos
//
// struct GSArgs {
// 	filter  string		//if used will only show the repo's which have the filter string inside
// 	pull    bool		// means when getting new repo will pull even when repo is already tehre
// 	force   bool		// means we will force a pull and reset old content	
//
pub fn (mut gitstructure GitStructure) repos_print(args GSArgs) {
	mut r := [][]string{}
	for mut g in gitstructure.repos_get(args) {
		changed := g.changes() or { panic('issue in repo changes. ${err}') }
		pr := g.path_relative()
		if changed {
			r << ['- ${pr}', '${g.addr.branch}', 'CHANGED']
		} else {
			r << ['- ${pr}', '${g.addr.branch}', '']
		}
	}
	texttools.print_array2(r, '  ', true)
}

pub fn (mut gitstructure GitStructure) list(args GSArgs) {
	texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)
	println('')
}

// reload the full git tree
fn (mut gitstructure GitStructure) reload() ! {
	gitstructure.status = GitStructureStatus.init

	if !os.exists(gitstructure.codepath()) {
		os.mkdir_all(gitstructure.codepath())!
	}

	gitstructure.check()!
}

// the factory for getting the gitstructure
// git is checked uderneith $/code
fn (mut gitstructure GitStructure) load() ! {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}

	// print_backtrace()
	// println(' - SCAN GITSTRUCTURE FOR $root2 ')

	// println(" -- multibranch: $multibranch")

	gitstructure.repos = []GitRepo{}

	mut done := []string{}

	// path which git repos will be recursively loaded
	git_path := gitstructure.codepath() + '/github'
	gitstructure.load_recursive(git_path, mut done)!

	gitstructure.status = GitStructureStatus.loaded

	// println(" - SCAN done")
}

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ! {
	// println(" - git load: $path1")
	if !(os.exists(path1)) {
		os.mkdir_all(path1)!
	}
	items := os.ls(path1) or {
		return error('cannot load gitstructure because cannot find ${path1}')
	}
	mut pathnew := ''
	for item in items {
		pathnew = os.join_path(path1, item)
		// CAN DO THIS LATER IF NEEDED
		// if pathnew in done{
		// 	continue
		// }
		// done << pathnew
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if os.exists(os.join_path(pathnew, '.git')) {
				gitaddr := addr_get_from_path(pathnew) or { return err }
				gitstructure.repos << GitRepo{
					addr: gitaddr
					path: pathnew
					id: gitstructure.repos.len
					gs: &gitstructure
				}
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load_recursive(pathnew, mut done)!
		}
	}
	// println(" - git exit: $path1")
}

pub fn (mut gs GitStructure) codepath() string {
	mut p := ''
	if gs.config.multibranch {
		p = gs.config.root + '/multi'
	} else {
		p = gs.config.root
	}
	// println(" ***** $p")
	return p
}
