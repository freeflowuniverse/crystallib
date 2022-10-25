module actionrunner
import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.books

pub fn execute(path string) ? {
	mut parser := actionparser.get()
	parser.file_parse(path)?

	println(parser.actions)

	mut actions_done := map[string]string{}

	// these are the std actions as understood by the action parser
	actions_done = actions_process(mut parser actionparser.ActionsParser, actions_done)?
	actions_done = books.actions_process(mut parser actionparser.ActionsParser, actions_done)?



	println(result)
}
