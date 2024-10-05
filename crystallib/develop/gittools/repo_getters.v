module gittools

//import freeflowuniverse.crystallib.ui.console


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

pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) ![]&GitRepo {
	mut args := ReposGetArgs{
		...args_
	}
	// console.print_debug(args)
	mut res := []&GitRepo{}
	// repos.sort()
	// console.print_debug(repos.join("\n"))
	for _,r in gitstructure.repos {
		relpath := r.path_relative()!
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// console.print_debug("MATCH: $args.filter")
				res << r
			}
			continue
		}
		if args.name.len > 0 && args.name != r.name {
			continue // means no match
		}
		if args.account.len > 0 && args.account != r.account {
			continue // means no match
		}
		if args.provider.len > 0 && args.provider != r.provider {
			continue // means no match
		}
		res << r
	}

	// console.print_debug(res)
	// if true{panic("s")}

	return res
}


pub fn (mut gitstructure GitStructure) repo_get(args ReposGetArgs) !&GitRepo {

	res := gitstructure.repos_get(args)!
	if res.len == 0 {
		return error('cannot find repo with locator.\n${args}')
	}
	if res.len > 1 {
		repos := res.map('- ${it.account}.${it.name}').join_lines()
		return error('Found more than 1 repo for \n${args}\n${repos}')
	}
	return res[0] or { panic('bug') }
}


pub fn (mut gitstructure GitStructure) repo_exists(args ReposGetArgs) !bool {
	res := gitstructure.repos_get(args)!
	if res.len == 0 {
		return false
	}
	if res.len > 1 {
		return error('Found more than 1 repo with locator (exist).\n${args}\n${res}')
	}
	return true
}



pub fn (mut gitstructure GitStructure) repo_get_from_locator(l GitLocation) !&GitRepo {

	return gitstructure.repo_get(name: l.name, account: l.account,provider:l.provider)!

}

pub fn (mut gitstructure GitStructure) repo_exists_from_locator(l GitLocation) !bool {

	return gitstructure.repo_exists(name: l.name, account: l.account,provider:l.provider)!

}



// will get repo starting from url, if the repo does not exist, only then will pull .
// if pull is set on true, will then pull as well .
// url examples: .
// ```
// https://github.com/threefoldtech/tfgrid-sdk-ts
// https://github.com/threefoldtech/tfgrid-sdk-ts.git
// git@github.com:threefoldtech/tfgrid-sdk-ts.git
//
// # to specify a branch and a folder in the branch
// https://github.com/threefoldtech/tfgrid-sdk-ts/tree/development/docs
//
// args:
// path   string
// url    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
// ```
// will return the path of the location 
pub fn (mut gs GitStructure) code_get(args GSCodeGetFromUrlArgs) !string {

	mut gl:=GitLocation{}

	if args.path.len>0{
		gl=gs.gitlocation_from_path(args.path)!
	}
	if args.url.len>0{
		gl=gs.gitlocation_from_url(args.url)!
	}	


	if ! gs.repo_exists(provider:gl.provider, account:gl.account, name:gl.name)!{
		panic("implement clone...")
		
	}
	mut r:=gs.repo_get(provider:gl.provider, account:gl.account, name:gl.name)!


	//TODO: IMPORTANT NEED TO CHECK DEPENDING SITUATION WHAT TO DO
	if args.reload{
		panic("implement")
	}	
	if args.reset{
		panic("implement")
	}
	if args.branch.len>0{
		//TODO check what to do
		panic("implement")
	}
	if args.tag.len>0{
		panic("implement")
	}

	if args.pull{
		panic("implement")
	}



	return gl.patho()!.path

}


// @[params]
// pub struct GitRepoGetArgs {
// pub mut:
// 	gitstructure_name string = 'default'
// 	path              string
// }

// // look for git dir at (.git location), .
// // if path not specified will take current path, .
// // will give error if we can't find the .git location .
// // will then opern repo from that location
// //```
// // params:
// // 		path string
// // 		coderoot string
// //```
// pub fn git_repo_get(args_ GitRepoGetArgs) !GitRepo {
// 	mut args := args_
// 	path := git_dir_get(path: args.path)!
// 	mut gs := get(name: args.gitstructure_name) or {
// 		return error("Could not load gittools for ${args.gitstructure_name}'\n${err}")
// 	}
// 	return gs.repo_from_path(path)
// }
