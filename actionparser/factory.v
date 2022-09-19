module actionparser

pub fn execute(path string) ? {
	mut parser := get()
	parser.file_parse(path)?

	println(parser.actions)

	// these are the std actions as understood by the action parser
	result := parser.actions_process()?

	println(result)
}
