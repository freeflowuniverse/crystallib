module actions

import os

pub fn get() ActionsManager {
	return ActionsManager{}
}

// parse text to actions struct
pub fn text_parse(content string) !ActionsManager {
	mut actions := get()

	actions.text_parse(content)!

	return actions
}

pub fn file_parse(path string) !ActionsManager {
	mut actions := get()
	actions.file_parse(path)!

	return actions
}

// walk over all files of a dir and return list of actions with its parameters
pub fn dir_parse(path string) !ActionsManager {
	mut actions := get()
	actions.add(path)!
	return actions
}

// path can be a directory or a file
pub fn (mut actions ActionsManager) add(path string) ! {
	// recursive behavior for when dir
	// println(" -- add: $path")
	if os.is_dir(path) {
		mut items := os.ls(path)!
		items.sort() // make sure we sort the items before we go in
		// process dirs first, make sure we go deepest possible
		for path0 in items {
			pathtocheck := '${path}/${path0}'
			if os.is_dir(pathtocheck) {
				actions.add(pathtocheck)!
			}
		}
		// now process files in order
		for path1 in items {
			pathtocheck := '${path}/${path1}'
			if os.is_file(pathtocheck) {
				actions.add(pathtocheck)!
			}
		}
	}

	// make sure we only process markdown files
	if os.is_file(path) {
		if path.to_lower().ends_with('.md') {
			actions.file_parse(path)!
		}
	}
}
