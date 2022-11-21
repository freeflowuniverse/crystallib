module actionparser

import os

pub fn get() ActionsParser {
	return ActionsParser{}
}

// path can be a directory or a file
pub fn (mut parser ActionsParser) add(path string) ! {
	// recursive behavior for when dir
	if os.is_dir(path) {
		mut items := os.ls(path)!
		items.sort() // make sure we sort the items before we go in
		// process dirs first, make sure we go deepest possible
		for path0 in items {
			if os.is_dir(path0) {
				parser.add(path0)!
			}
		}
		// now process files in order
		for path1 in items {
			if os.is_file(path1) && path.to_lower().ends_with('.md') {
				parser.add(path1)!
			}
		}
	}
	// make sure we only process markdown files
	if os.is_file(path) && path.to_lower().ends_with('.md') {
		parser.file_parse(path)!
	}
}

// parse text to actions struct
pub fn text_parse(content string) !ActionsParser {
	mut parser := get()

	parser.text_parse(content)!

	return parser
}

pub fn file_parse(path string) !ActionsParser {
	mut parser := get()
	parser.file_parse(path)!

	return parser
}
