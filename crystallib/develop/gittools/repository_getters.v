module gittools

import freeflowuniverse.crystallib.ui.console


//are the getters they do not take into consideration any manipulation of tags or branches (pull, reset, ...)


// get a list of repo's which are in line to the args
//
@[params]
pub struct ReposGetArgs {
pub mut:
	filter   string // if used will only show the repo's which have the filter string inside
	name     string
	account  string
	provider string //e.g. github
}

pub fn (a ReposGetArgs) str() string {
	mut out := ''
	if a.filter.len > 0 {
		out += 'filter:${a.filter} '
	}
	if a.name.len > 0 {
		out += 'name:${a.name} '
	}
	if a.account.len > 0 {
		out += 'account:${a.account} '
	}
	if a.provider.len > 0 {
		out += 'provider:${a.provider} '
	}
	return out.trim_space()
}

pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) []&GitRepo {
	mut args := ReposGetArgs{
		...args_
	}
	// console.print_debug(args)
	gitstructure.check() or { panic(err) }
	mut res := []GitRepo{}
	// repos.sort()
	// console.print_debug(repos.join("\n"))
	for r in gitstructure.repos {
		relpath := r.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// console.print_debug("MATCH: $args.filter")
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

	// console.print_debug(res)
	// if true{panic("s")}

	return res
}


pub fn (mut gitstructure GitStructure) repo_get(args_ ReposGetArgs) !&GitRepo {

	res := gitstructure.repos_get(name: l.addr.name, account: l.addr.account)
	if res.len == 0 {
		return error('cannot find repo with locator.\n${l}')
	}
	if res.len > 1 {
		repos := res.map('- ${it.addr.account}.${it.addr.name}').join_lines()
		return error('Found more than 1 repo with locator.\n${l}\n${repos}')
	}
	return res[0] or { panic('bug') }
}


pub fn (mut gitstructure GitStructure) repo_exists(args_ ReposGetArgs) !bool {
	res := gitstructure.repos_get(name: l.addr.name, account: l.addr.account,provider:l.addr.provider)
	if res.len == 0 {
		return false
	}
	if res.len > 1 {
		return error('Found more than 1 repo with locator (exist).\n${l}\n${res}')
	}
	return true
}


pub fn (mut gitstructure GitStructure) repo_get_from_locator(l GitLocator) !&GitRepo {

	return repo_get(name: l.addr.name, account: l.addr.account,provider:l.addr.provider)!

}

pub fn (mut gitstructure GitStructure) repo_exists_from_locator(l GitLocator) !bool {

	return repo_exists(name: l.addr.name, account: l.addr.account,provider:l.addr.provider)!

}
