module gittools

import os
import freeflowuniverse.crystallib.pathlib

const (
	gitstructure_name = 'test_gitstructure'
	gitstructure_root = '${os.home_dir()}/testroot'
)

// get new gitstructure .
// args .
//```
// pub struct GSConfig {
//  name        string = "default"
// 	multibranch bool
// 	root        string // where will the code be checked out
// 	light       bool   // if set then will clone only last history for all branches		
// 	log         bool   // means we log the git statements
// }
//```
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
fn test_new() ! {
	new(
		name: gittools.gitstructure_name
		root: gittools.gitstructure_root
		multibranch: false
		light: false
		log: true
	)!
}
