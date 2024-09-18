
module processor

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctreemodel
import os



pub fn page_process(mut collection doctreemodel.Collection, path string) {	

	mut doc := markdownparser.new(content: page.doc()!.markdown()!)!
	page.doc_ = &doc

	page.doc_process()!

	// console.print_debug(' ++++ export: ${page.name} -> ${args.dest}')
	mut p := pathlib.get_file(path: args.dest, create: true)!
	dirpath := p.parent()!
	// mut mydoc := page.doc()!
	mut mydoc := page.doc_process_link(dest: dirpath.path)!
	p.write(mydoc.markdown()!)!
	return mydoc
}