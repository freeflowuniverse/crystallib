module installers

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools

pub struct BinPushArgs{
pub mut:
	cmdname string
	source string
	bin_repo_url string = "https://github.com/freeflowuniverse/freeflow_binary" //binary where we put the results
}

pub fn bin_push (args BinPushArgs)!{
	mut sourcepath:=pathlib.get_file(path:args.source,create:false)!
	sourcepath.copy(dest:"/usr/local/bin/${args.cmdname}")!
	mut repo := gittools.repo_get(url: args.bin_repo_url, reset: false, pull: true)!
	sourcepath.copy(dest:"${repo.path.path}/x86_64/${args.cmdname}")!
	repo.commit_pull_push(msg:"new binary for ${args.cmdname} for linux")!
		
}