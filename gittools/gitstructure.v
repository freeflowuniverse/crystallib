module gittools

import freeflowuniverse.crystallib.pathlib

pub struct RepoGetFromUrlArgs {
pub mut:
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
	mut addr := addr_get_from_url(args.url) or { return error('cannot get addr from url:$err') }

	if addr.branch != '' && args.branch != '' && addr.branch != args.branch {
		return error('conflict in branch names.\naddr:\n$addr\nargs:\n$args')
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
pub fn (mut gitstructure GitStructure) repo_get_from_addr(addr GitAddr, args RepoGetFromUrlArgs) ?&GitRepo {
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
		}
		mut r0 := gitstructure.repo_get(args2) or {
			// means could not pull need to remove the repo from the list again
			gitstructure.repos.delete_last()
			return error('Could not find repo ${args2.account}.$args2.name \nError:$err')
		}
		// println (" GIT REPO GET URL: PULL:$args.pull, RESET: $args.reset\n$r0.addr")
		r0.check(args.pull, args.reset)?
		return r0
	} else {
		mut r := gitstructure.repo_get(args2) or { return error('cannot load git $args.url\n$err') }
		r.addr = addr
		// println (" GIT REPO GET PULL:$args.pull, RESET: $args.reset")
		r.check(args.pull, args.reset)?
		return r
	}
}

// will return repo starting from a path
// if .git not in the path will go for parent untill .git found
pub fn (mut gitstructure GitStructure) repo_get_from_path(p string, pull bool, reset bool) ?&GitRepo {
	mut pathobj := pathlib.get(p)
	path2 := pathobj.parent_find('.git')?

	mut addr := addr_get_from_path(path2.path) or { return error('cannot get addr from path:$err') }
	// println(" - pull:$pull reset:$reset")
	args := RepoGetFromUrlArgs{
		pull: pull
		reset: reset
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
pub fn (mut gitstructure GitStructure) repo_get(args RepoGetArgs) ?&GitRepo {
	mut res_ids := []int{}
	for r in gitstructure.repos {
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
		return error("Found too many repo's for account:'$args.account' name:'$args.name'")
	}
	// print_backtrace()
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
