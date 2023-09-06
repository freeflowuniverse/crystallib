module gittools

import os
import freeflowuniverse.crystallib.pathlib

[params]
pub struct GSConfig {
pub mut:
	filter      string
	multibranch bool
	root        string // where will the code be checked out
	pull        bool   // means we will pull even if the directory exists
	reset       bool   // be careful, this means we will reset when pulling
	light       bool   // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
}

// struct GSConfig{
// filter string
// multibranch bool
// root string	//where will the code be checked out
// pull bool   //means we will pull even if the directory exists
// reset bool  //be careful, this means we will reset when pulling
// light       bool  // if set then will clone only last history for all branches		
// }
pub fn get(config GSConfig) !GitStructure {
	mut gs := GitStructure{
		config: config
	}

	if 'MULTIBRANCH' in os.environ() {
		gs.config.multibranch = true
	}

	if 'DIR_CODE' in os.environ() {
		gs.config.root = os.environ()['DIR_CODE'] + '/'
	}
	if gs.config.root == '' {
		gs.config.root = '${os.home_dir()}/code/'
	}

	gs.config.root = gs.config.root.replace('~', os.home_dir()).trim_right('/')

	gs.rootpath = pathlib.get_dir(gs.config.root,true)!

	gs.status = GitStructureStatus.init // step2

	gs.check()!

	return gs
}

pub struct CodeGetFromUrlArgs {
pub mut:
	url    string
	branch string
	pull   bool   // will pull if this is set
	reset  bool   // this means will pull and reset all changes
	root   string // where code will be checked out
}

// will get repo starting from url, if the repo does not exist, only then will pull .
// if pull is set on true, will then pull as well .
// struct RepoGetFromUrlArgs { .
// .
// 	url    string .
// 	branch string .
// 	pull   bool // will pull if this is set .
// 	reset bool //this means will pull and reset all changes .
// } .
pub fn code_get(args CodeGetFromUrlArgs) !string {
	mut gs := get(root: args.root)!
	mut gr := gs.repo_get_from_url(url: args.url, pull: args.pull, reset: args.reset)!
	return gr.path_content_get()
}
