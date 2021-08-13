module gittools

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
	gitstructure.check() ?

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
			gitstructure: &gitstructure
			addr: addr
			id: gitstructure.repos.len
		}
		mut r0 := gitstructure.repo_get(args2) or {
			// means could not pull need to remove the repo from the list again
			gitstructure.repos.delete_last()
			return error('Could not clone the repo from ${args.url}.\nError:$err')
		}
		// println (" GIT REPO GET URL: PULL:$args.pull, RESET: $args.reset\n$r0.addr")
		r0.check(args.pull, args.reset) ?
		return r0
	} else {
		mut r := gitstructure.repo_get(args2) or { return error('cannot load git $args.url\nerr') }
		r.addr = addr
		// println (" GIT REPO GET URL: PULL:$args.pull, RESET: $args.reset")
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
	gitstructure.check() ?

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
		return error("Found too many repo's for account:'$args.account' name:'$args.name'")
	}
	return error("Could not find repo for account:'$args.account' name:'$args.name'")
}

// to use gitstructure.repo_get({account:"something",name:"myname"})
// or gitstructure.repo_get({name:"myname"})
pub fn (mut gitstructure GitStructure) repo_exists(addr RepoGetArgs) bool {
	gitstructure.check() or { panic('cannot check gitstructure, $err') }

	for r in gitstructure.repos {
		if r.addr.name == addr.name {
			if addr.account == '' || addr.account == r.addr.account {
				return true
			}
		}
	}
	return false
}
