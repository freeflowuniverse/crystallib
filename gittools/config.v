module gittools

import os

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

	if !os.exists(gs.config.root) {
		os.mkdir_all(gs.config.root)!
	}

	gs.status = GitStructureStatus.init // step2

	gs.check()!

	return gs
}
