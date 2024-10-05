module gittools

import os
import freeflowuniverse.crystallib.core.pathlib
import crypto.md5

@[params]
pub struct CodeGetFromUrlArgs {
	GSCodeGetFromUrlArgs
pub mut:
	coderoot          string
	gitstructure_name string = 'default'
}

pub fn (self CodeGetFromUrlArgs) gs_code_get_args() !GSCodeGetFromUrlArgs{
    mut gs_args := GSCodeGetFromUrlArgs{
		path: self.path
        url: self.url
        branch: self.branch
        tag: self.tag
        sshkey: self.sshkey
        pull: self.pull
        reset: self.reset
        reload: self.reload
    }
    if gs_args.url == '' {
        return error('URL is required for ${self}')
    }
    return gs_args
}


pub struct GSCodeGetFromUrlArgs {
pub mut:
	path    string
	url    string
	branch string
	tag string
	sshkey string
	pull   bool // will pull if this is set
	reset  bool // this means will pull and reset all changes
	reload bool // reload the cache	
}

pub fn (self GSCodeGetFromUrlArgs) str() string{
	mut msg:='code get args url:\'${self.url}\''
	if args.path!=""{
		msg='code get args: path:\'${self.path}\''
	}
	if args.branch!=""{
		msg+=" branch:\'${self.branch}\'"
	}
	if args.tag!=""{
		msg+=" tag:\'${self.tag}\'"
	}
	if args.pull{
		msg+=" pull"
	}	
	if args.reset{
		msg+=" reset"
	}	
	return msg
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
// args:
// coderoot          string
// gitstructure_name string = 'default' // optional, if not mentioned is default, tmp is another good one
// url               string
// tag               string
// branch            string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
// ```
pub fn code_get(args CodeGetFromUrlArgs) !string {
	mut gs := get()!
	mut name := args.gitstructure_name
	//	console.print_debug(args.str())
	if args.coderoot.len > 0 {
		name = md5.hexhash(args.coderoot)
		gs = new(name: name, root: args.coderoot)!
	} else {
		gs = get(name: args.gitstructure_name)!
	}
	return gs.code_get(url: args.url, pull: args.pull, reset: args.reset, reload: args.reload,tag:args.tag, branch:args.branch)
}

pub fn repo_get(args CodeGetFromUrlArgs) !GitRepo {
	mut gs := get(name: args.gitstructure_name)!
	mut locator := gs.locator_new(args.url)!
	// console.print_debug(locator)
	mut g := gs.repo_get(locator: locator)!
	if args.reload {
		g.load()!
	}
	if args.reset {
		g.remove_changes()!
	}
	return g
}

@[params]
pub struct GitDirGetArgs {
pub mut:
	path string
}

// look for git dir at (.git location),
// if path not specified will take current path,
// will give error if we can't find the .git location
//```
// params:
// 		path string
//```
pub fn git_dir_get(args_ GitDirGetArgs) !string {
	mut args := args_
	if args.path == '' {
		args.path = os.getwd()
	}

	mut curdiro := pathlib.get_dir(path: args.path, create: false)!
	mut parentpath := curdiro.parent_find('.git') or {
		return error('cannot find git dir in ${args.path}')
	}

	return parentpath.path
}

@[params]
pub struct GitRepoGetArgs {
pub mut:
	gitstructure_name string = 'default'
	path              string
}

// look for git dir at (.git location), .
// if path not specified will take current path, .
// will give error if we can't find the .git location .
// will then opern repo from that location
//```
// params:
// 		path string
// 		coderoot string
//```
pub fn git_repo_get(args_ GitRepoGetArgs) !GitRepo {
	mut args := args_
	path := git_dir_get(path: args.path)!
	mut gs := get(name: args.gitstructure_name) or {
		return error("Could not load gittools for ${args.gitstructure_name}'\n${err}")
	}
	return gs.repo_from_path(path)
}
