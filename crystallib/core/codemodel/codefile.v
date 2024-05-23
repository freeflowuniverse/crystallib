module codemodel

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import os

pub struct CodeFile {
pub mut:
	name    string
	mod     string
	imports []Import
	items   []CodeItem
	content string
}

pub fn new_file(config CodeFile) CodeFile {
	return CodeFile{
		...config
		mod: texttools.name_fix(config.mod)
		items: config.items
	}
}

pub fn (code CodeFile) write_v(path string, options WriteOptions) ! {
	filename := '${options.prefix}${texttools.name_fix(code.name)}.v'
	mut filepath := pathlib.get('${path}/${filename}')

	if !options.overwrite && filepath.exists() {
		return
	}

	imports_str := code.imports.map(it.vgen()).join_lines()

	code_str := if code.content != '' {
		code.content
	} else {
		vgen(code.items)
	}

	mut file := pathlib.get_file(
		path: filepath.path
		create: true
	)!
	file.write('module ${code.mod}\n${imports_str}\n${code_str}')!
	if options.format {
		os.execute('v fmt -w ${file.path}')
	}
}
