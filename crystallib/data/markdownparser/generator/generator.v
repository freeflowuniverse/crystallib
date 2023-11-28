module main

import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

@[params]
struct ElementCat {
mut:
	name      string
	classname string
	overwrite bool
}

fn new(args_ ElementCat) ElementCat {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	if args.classname == '' {
		args.classname = args.name[0..1].to_upper()
		args.classname += args.name[1..]
		if args.classname.contains('_') {
			panic('Cannot have _ name if classname not specified.')
		}
	}
	return args
}

fn get_generator_names() []ElementCat {
	mut elementsobj := []ElementCat{}

	// HERE ADD YOUR DIFFERENT ELEMENTS
	// elementsobj << new(name: 'doc')
	// elementsobj << new(name: 'none')
	elementsobj << new(name: 'html')	
	elementsobj << new(name: 'paragraph')
	elementsobj << new(name: 'action')
	elementsobj << new(name: 'table')
	elementsobj << new(name: 'header')
	elementsobj << new(name: 'text')
	elementsobj << new(name: 'comment')
	elementsobj << new(name: 'include')
	elementsobj << new(name: 'codeblock')
	elementsobj << new(name: 'link')
	return elementsobj
}

fn do() ! {
	elementsobj := get_generator_names()
	println(elementsobj)

	outpathloc := os.dir(@FILE) + '/../elements/'

	// e.g.	type DocElement = Action | Codeblock | Text | None
	mut elementtypes := ''
	for element in elementsobj {
		elementtypes += '${element.classname} | '
	}
	elementtypes = elementtypes.trim_right(' |')

	content := $tmpl('templates/generated.vtemplate').replace('&&', '$')
	gpath := '${outpathloc}/generated.v'
	mut outpath := pathlib.get_file(path: gpath, create: true)!
	println(' - write ${gpath}')
	outpath.write(content)!

	for eo in elementsobj {
		content2 := $tmpl('templates/element_x.vtemplate')
		e_path := '${outpathloc}/element_${eo.name}.v'
		if !os.exists(e_path) || eo.overwrite {
			mut outpath2 := pathlib.get_file(path: e_path, create: true)!
			println(' - write ${e_path}')
			outpath2.write(content2)!
		}
	}
}

fn main() {
	do() or { panic(err) }
}
