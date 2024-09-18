module doctreemodel

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements { Doc }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.ui.console


@[heap]
pub struct Page {
	Base
pub mut:
	alias   string // a proper name for e.g. def
	doc_            ?&Doc    @[str: skip]
}

//text before processing
pub fn (mut self Page) text() !string {
	if self.ext.len>0{
		return error("can only get text on markdown docs")
	}
	self.pathobj()
	mut p := pathlib.get_file(path: args.dest, create: true)!
	return p.read()!

}

//is the document which represents all elements making up a markdown doc
pub fn (mut self Page) doc() !&Doc {
	mut doc0:= self.doc_ or {
		mut doc := markdownparser.new(content: self.text()!)!
		doc
	}
	page.doc_ = &doc0

	return page.doc_
}

pub fn (mut self Page) markdown() !str {

	//mut mydoc := page.doc_process_link(dest: dirpath.path)!
	// page.doc_process()!
	// dirpath := p.parent()!
	// mut mydoc := page.doc()!
	// mut mydoc := page.doc_process_link(dest: dirpath.path)!

	mut doc:=self.doc()!
	m:=doc.markdown()!

	return m
}

pub fn (mut self Page) markdown_write(path string) ! {
	mut p := pathlib.get_file(path: path, create: true)!
	dirpath := p.parent()!
	p.write(self.markdown()!)!
}
