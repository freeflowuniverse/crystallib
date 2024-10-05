module gittools

import freeflowuniverse.crystallib.ui.console




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
// url    string
// path    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
// ```
// cannot specify path and url at same time
pub fn (mut gs GitStructure) repo_load(args_ GSCodeGetFromUrlArgs) !&GitRepo {

	mut args:=args_

	args.pull = args.reset || args.pull || args.tag.len>0  || args.branch.len>0
	
	console.print_header(args.str()) 

	//first check if the repo exists

	mut myrepo := GitRepo{gs:&gs,addr:&GitAddr{GitStructureConfig:gs.config}}

	


	// console.print_debug('repo_add:${args}')
	if args.path.len > 0 {
		if args.url!=""{
			return error("can't get repo if url specified.")
		}		
		myrepo = gs.repo_from_path_(args.path)!
	} else{
		mut locator := gs.locator_new(args.url)!
		if args.branch.len > 0 {
			locator.addr.branch = args.branch
		}
		if args.tag.len > 0 {
			locator.addr.tag = args.tag
		}	
		// console.print_debug('got locator ${locator}')
		myrepo = gs.repo_from_locator_(locator: locator, reset: args.reset, pull: args.pull)!
		// console.print_debug('got repo ${repo}')

	}
	if args.sshkey.len > 0 {
		repo.ssh_key_set(args.sshkey)!
	}


	if args.reset {
		console.print_header(' remove git changes: ${r.path.path}')
		r.remove_changes(reload: false)!
	}

	// if args.reset {
	// 	//when tags specified cannot remove changes
	// 	if args.tag==""{
	// 		myrepo.remove_changes()!
	// 	}
		
	// }
	// if args.pull || args.reset {
	// 	myrepo.pull(tag:args.tag,branch:args.branch)!
	// }


	if r2.addr.branch != '' {
		st := r2.status()!
		mut branchname := st.branch
		//console.print_debug(" - branch detected: $branchname, branch on repo obj:'$r2.addr.branch'")
		// println(st)
		// println(r2)
		if st.branch != r2.addr.branch && args.pull {
			//console.print_header(' branch switch ${branchname} -> ${r2.addr.branch} for ${r2.addr.remote_url}')
			r2.branch_switch(r2.addr.branch)!
		}
		// } else {
		// 	print_backtrace()
		// 	return error('branch should have been known for ${r2.addr.remote_url}')
	}
		
	if args.pull {
		r.pull(tag:args.tag)!
	} else {
		r.status()!
	}
	r.load()!

	gitstructure.repo_set_(&r)!

	return repo
}


fn (mut gitstructure GitStructure) repo_from_path_(path string) !GitRepo {
	// find parent with .git
	// console.print_debug(" - load from path: $path")
	mypath := pathlib.get_dir(path: path, create: false)!
	mut parentpath := mypath.parent_find('.git') or {
		return error('cannot find .git in parent starting from: ${path}')
	}
	if parentpath.path == '' {
		return error('cannot find .git in parent starting from: ${path}')
	}
	mut ga := GitAddr{
		gsconfig: &gitstructure.config
	}
	mut r := GitRepo{
		gs: &gitstructure
		addr: &ga
		status: &GitRepoStatus{}
		path: parentpath
	}
	r.load_from_path()!
	return r
}




// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
fn (mut gitstructure GitStructure) repo_from_locator_(args_ RepoGetFromLocatorArgs) !GitRepo {
	mut args := args_


	p := args.locator.addr.path()!

	mut r := if gitstructure.repo_exists(args.locator)! {
		gitstructure.repo_get_from_locator(args.locator)!
	} else {
		// console.print_debug("repo does not exist:\n$p\n+++")
		// if repo doesn't exist, create new repo from address in locator
		mut r2 := GitRepo{
			gs: &gitstructure
			addr: args.locator.addr
			path: p
		}
		r2.load_from_url()!
		r2.path.check() // make sure we check state of path
		r2
	}


	return r
}
