module markdowndocs

//get the document (is parsed version)
pub fn get(path string) !Doc {
	mut doc:=Doc{}
	mut parser := Parser{doc:&doc}
	parser.file_parse(path)!
	return parser.doc
}
