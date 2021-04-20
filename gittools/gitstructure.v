module gittools

import os

pub struct RepoGetFromUrlArgs {
mut:
	url    string
	branch string
	pull   bool // will pull if this is set
	reset  bool // this means will pull and reset all changes
}

// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
// struct RepoGetFromUrlArgs {
// 	url    string
// 	branch string
// 	pull   bool // will pull if this is set
// 	reset bool //this means will pull and reset all changes
// }
pub fn (mut gitstructure GitStructure) repo_get_from_url(args RepoGetFromUrlArgs) ?&GitRepo {
	mut addr := gitstructure.addr_get_from_url(args.url) or {
		return error('cannot get addr from url:$err')
	}
	if addr.branch != '' && args.branch != '' && addr.branch != args.branch {
		return error('conflict in branch names.\naddr:\n$addr\nargs:\n$args')
	}
	if addr.branch == '' {
		addr.branch = args.branch
	}
	args2 := RepoGetArgs{
		name: addr.name
		account: addr.account
	}
	if !gitstructure.repo_exists(args2) {
		// repo does not exist yet
		gitstructure.repos << GitRepo{
			path: addr.path_get()
			addr: addr
			id: gitstructure.repos.len
		}
		mut r0 := gitstructure.repo_get(args2) or {
			// means could not pull need to remove the repo from the list again
			gitstructure.repos.delete_last()
			return error('Could not clone the repo from ${args.url}.\nError:$err')
		}
		r0.check(args.pull, args.reset) ?
		return r0
	} else {
		mut r := gitstructure.repo_get(args2) or { return error('cannot load git $args.url\nerr') }
		r.addr = addr
		r.check(args.pull, args.reset) ?
		return r
	}
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
pub fn (mut gitstructure GitStructure) repo_get(args RepoGetArgs) ?&GitRepo {
	for r in gitstructure.repos {
		if r.addr.name == args.name {
			if args.account == '' || args.account == r.addr.account {
				mut r2 := &gitstructure.repos[r.id]
				return r2
			}
		}
	}
	return error("Could not find repo for account:'$args.account' name:'$args.name'")
}

// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_exists(addr RepoGetArgs) bool {
	for r in gitstructure.repos {
		if r.addr.name == addr.name {
			if addr.account == '' || addr.account == r.addr.account {
				return true
			}
		}
	}
	return false
}

// find all git repo's, this goes very fast, no reason to cache
fn (mut gitstructure GitStructure) load() ? {
	gitstructure.repos = []GitRepo{}
	if gitstructure.root == '' {
		gitstructure.root = '$os.home_dir()/code/'
	}
	gitstructure.root = gitstructure.root.replace('~', os.home_dir())
	return gitstructure.load_recursive(gitstructure.root)
}

fn (mut gitstructure GitStructure) load_recursive(path1 string) ? {
	items := os.ls(path1) or { return error('cannot load gitstructure because cannot find $path1') }
	mut pathnew := ''
	for item in items {
		pathnew = os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if os.exists(os.join_path(pathnew, '.git')) {
				gitaddr := gitstructure.addr_get_from_path(pathnew) or { return err }
				gitstructure.repos << GitRepo{
					addr: gitaddr
					path: pathnew
					id: gitstructure.repos.len
				}
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load_recursive(pathnew) ?
		}
	}
}
