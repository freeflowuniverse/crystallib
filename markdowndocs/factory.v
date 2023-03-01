module markdowndocs
import pathlib
import os

[params]
pub struct NewDocArgs{
pub:
	path string	
	content string
}

//get a parsed document, path is the path to the file, if not given content is needed
pub fn new(args NewDocArgs) !Doc {
	mut doc := Doc{}	
	if args.path == "" {
		if args.content.trim_space() == "" {
			return error("cannot process doc where content is empty if path not given. \n$args")
		}
		doc.content = args.content
	}else{
		if args.path.trim_space() == "" {
			return error("cannot process doc where path is empty and content empty \n$args")
		}
		
		path2 := pathlib.get_file(args.path, false)!
		doc.path = path2
		doc.content = os.read_file(args.path) or { return error('Failed to load file ${args.path}') }
	}
	doc.parse()!
	return doc
}

