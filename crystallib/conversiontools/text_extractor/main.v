module main

import os
import flag
import freeflowuniverse.crystallib.ui.console

fn convert_to_text(path string) !os.Result {
	if !os.exists(path) {
		return error("${path} doesn't exist")
	}
	path_clean := path.replace(' ', '\\ ')
	res := os.execute('extractor ${path_clean}')
	return res
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('text extractor')
	fp.version('v0.0.1')
	fp.skip_executable()
	file_path := fp.string('path', `p`, '', 'path where the file exists')

	content := convert_to_text('${file_path}') or { panic(err) }
	console.print_debug(content)
}
