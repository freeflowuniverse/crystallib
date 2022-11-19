module actionrunner

import freeflowuniverse.crystallib.actionparser
import os
// struct ActionRunner{
// pub mut:

// }

//will look for
// export RUNNERDOC=https://gist.github.com/despiegk/linknotspecified
// if the env argument found will get the code and execute
pub fn run_env() ! {
	mut parser := actionparser.get()

	if "RUNNERDOC" in os.environ(){
		link:=os.environ()["RUNNERDOC"]
		println(link)		
	}else{
		return error("cannot continue, looking for RUNNERDOC in ENV, do something like\nexport RUNNERDOC=https://gist.github.com/despiegk/linknotspecified")
	}

	// parser.text_parse(content)!

	// mut actions_done := map[string]string{}
	// actions_done = actions_process(mut parser, actions_done)!
	// println(actions_done)
}


//parse an actionrunner file
pub fn run_file(path string) ! {
	mut parser := actionparser.get()
	parser.file_parse(path)!

	mut actions_done := map[string]string{}

	// these are the std actions as understood by the action parser
	actions_done = actions_process(mut parser, actions_done)!

	println(actions_done)
}
