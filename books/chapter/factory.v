module chapter

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.pathlib

[params]
pub struct ChapterNewArgs {
pub mut:
	name string
	path string
	giturl string 
	git_reset bool
	git_pull bool
	heal bool  	//healing means we fix images, if selected will automatically load
	load bool
}



//get a new chapter
pub fn chapter_new(args_ ChapterNewArgs)!Chapter{
	mut args:=args_
	if args.giturl.len>0{
		mut gs := gittools.get()!
		mut gr := gs.repo_get_from_url(url: args.giturl, pull: args.git_pull, reset: args.git_reset)!
		args.path = gr.path		
	}
	mut pp:=pathlib.get_dir(args.path,false)!
	mut ch:=Chapter{
		name:args.name
		path:pp
		heal:args.heal
	}
	if args.load || args.heal {
		ch.scan()!
	}
	if args.heal{
		ch.fix()!
	}	
	return ch

}
