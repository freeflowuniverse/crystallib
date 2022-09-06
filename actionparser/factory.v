module actionparser

fn execute(path string)?{
	mut parser := actionparser.get()
	actionparser.file_parse(path)?

	println(parser.actions)

	//these are the std actions as understood by the action parser
	result := parser.actions_process()?

	println(result)

}