module markdowndocs

//get the document (is parsed version)
pub fn get(path string) !Doc {
	mut doc := parse_doc(path)!
	return doc
}
