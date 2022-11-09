module actionrunner

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.books

pub fn execute(path string) ? {
	mut parser := actionparser.get()
	parser.file_parse(path)?

	mut actions_done := map[string]string{}

	// these are the std actions as understood by the action parser
	actions_done = actions_process(mut parser, actions_done)?

	println(actions_done)
}
