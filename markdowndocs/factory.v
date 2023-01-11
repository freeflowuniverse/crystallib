module markdowndocs

//get the document (is parsed version)
pub fn get(path string) !Doc {
	doc := doc_parse(path)!
	// parser := parser_new(path)!
	return doc
}
