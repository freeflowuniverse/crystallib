module gittools

import os

pub struct RepoGetFromUrlArgs {
mut:
	url    string
	branch string = 'development'
	pull   bool // will pull if this is set
}

// will get repo starting from url, if the repo does not exist, only then will pull
pub fn (mut gitstructure GitStructure) repo_get_from_url(args RepoGetFromUrlArgs) ?&GitRepo {
	mut addr := gitstructure.addr_get_from_url(args.url) or {
		return error('cannot get addr from url:$err')
	}
	addr.branch = args.branch
	args2 := RepoGetArgs{
		name: addr.name
		account: addr.account
		pull: args.pull
	}
	if !gitstructure.repo_exists(args2) {
		// repo does not exist yet
		gitstructure.repos << GitRepo{
			path: addr.path_get()
			addr: addr
			id: gitstructure.repos.len
		}
		_ := gitstructure.repo_get(args2) or {
			// means could not pull need to remove the repo from the list again
			gitstructure.repos.delete_last()
			return error('Could not clone the repo from ${args.url}.\nError:$err')
		}
	}
	// println(args2)
	mut r := gitstructure.repo_get(args2) or { return error('cannot load git $args.url\nerr') }
	return r
}

pub struct RepoGetArgs {
mut:
	account string
	name    string // is the name of the repository
	pull    bool   // will pull if this is set
}

// will return first found git repo
// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_get(addr RepoGetArgs) ?&GitRepo {
	for r in gitstructure.repos {
		if r.addr.name == addr.name {
			if addr.account == '' || addr.account == r.addr.account {
				mut r2 := &gitstructure.repos[r.id]
				if !os.exists(r2.path) {
					// is not checked out yet need to do
					println(' - repo on $r2.path did not exist yet will pull.')
					r2.pull({}) ?
				}
				r2.check()
				return r2
			}
		}
	}
	return error("Could not find repo for account:'$addr.account' name:'$addr.name'")
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
