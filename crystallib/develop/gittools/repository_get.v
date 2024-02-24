module gittools

import freeflowuniverse.crystallib.ui.console

@[params]
pub struct RepoGetArgs {
pub mut:
	locator GitLocator
	pull    bool // if we want to pull when calling the repo
	reset   bool // if we want to force a clean repo
}

// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
pub fn (mut gitstructure GitStructure) repo_get(args_ RepoGetArgs) !GitRepo {
	mut args := args_
	args.pull = args_.reset || args_.pull


	p := args.locator.addr.path()!

	mut r := if gitstructure.repo_exists(args.locator)! {
		gitstructure.repo_get_internal(args.locator)!
	} else {
		// println("repo does not exist:\n$p\n+++")
		// if repo doesn't exist, create new repo from address in locator
		mut r2 := GitRepo{
			gs: &gitstructure
			addr: args.locator.addr
			path: p
		}
		r2.load_from_url()!
		if r2.addr.branch != '' {
			st := r2.status()!
			mut branchname := st.branch
			// println( " - branch detected: $branchname, branch on repo obj:'$r2.addr.branch'")
			if st.branch != r2.addr.branch && args.pull {
				console.print_header(' branch switch ${branchname} -> ${r2.addr.branch} for ${r2.addr.remote_url}')
				r2.branch_switch(r2.addr.branch)!
			}
			// } else {
			// 	print_backtrace()
			// 	return error('branch should have been known for ${r2.addr.remote_url}')
		}
		r2.path.check() // make sure we check state of path
		r2
	}

	if args.reset {
		console.print_header(' remove git changes: ${r.path.path}')
		r.remove_changes(reload: false)!
	}
	if args.pull {
		r.pull()!
	} else {
		r.status()!
	}
	return r
}

fn (mut gitstructure GitStructure) repo_get_internal(l GitLocator) !GitRepo {
	res := gitstructure.repos_get(name: l.addr.name, account: l.addr.account)
	if res.len == 0 {
		return error('cannot find repo with locator.\n${l}')
	}
	if res.len > 1 {
		repos := res.map('- ${it.addr.account}.${it.addr.name}').join_lines()
		return error('Found more than 1 repo with locator.\n${l}\n${repos}')
	}
	if res[0].addr.name != l.addr.name || res[0].addr.name != l.addr.name {
		panic('bug')
	}
	return res[0] or { panic('bug') }
}

pub fn (mut gitstructure GitStructure) repo_exists(l GitLocator) !bool {
	res := gitstructure.repos_get(name: l.addr.name, account: l.addr.account)
	if res.len == 0 {
		return false
	}
	if res.len > 1 {
		return error('Found more than 1 repo with locator (exist).\n${l}\n${res}')
	}
	return true
}

// get a list of repo's which are in line to the args
//
@[params]
pub struct ReposGetArgs {
pub mut:
	filter   string // if used will only show the repo's which have the filter string inside
	name     string
	account  string
	provider string
}

pub fn (a ReposGetArgs) str() string {
	mut out:=""
	if a.filter.len>0{
		out+="filter:${a.filter} "
	}
	if a.name.len>0{
		out+="name:${a.name} "
	}
	if a.account.len>0{
		out+="account:${a.account} "
	}
	if a.provider.len>0{
		out+="provider:${a.provider} "
	}
	return out.trim_space()
}

pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) []GitRepo {
	mut args := ReposGetArgs{
		...args_
	}
	// println(args)
	gitstructure.check() or {panic(err)}
	mut res := []GitRepo{}
	// repos.sort()
	// println(repos.join("\n"))
	for r in gitstructure.repos {
		relpath := r.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("MATCH: $args.filter")
				res << r
			}
			continue
		}
		if args.name.len > 0 && args.name != r.addr.name {
			continue // means no match
		}
		if args.account.len > 0 && args.account != r.addr.account {
			continue // means no match
		}
		if args.provider.len > 0 && args.provider != r.addr.provider {
			continue // means no match
		}
		res << r
	}

	// println(res)
	// if true{panic("s")}

	return res
}


