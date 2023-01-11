module markdowndocs

//get the document (is parsed version)
pub fn get(path string) !Doc {
	parser := parser_new(path)!
	return parser.doc
}
