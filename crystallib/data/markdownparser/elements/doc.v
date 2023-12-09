module elements

import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.data.actionparser

@[heap]
pub struct Doc {
pub mut:
	children []Element
	gid      smartid.GID
	pre      []HtmlSource
	lastid   int

	id      int
	content string
	// doc      ?&Doc        @[skip; str: skip]
	path      pathlib.Path
	processed bool
	params    paramsparser.Params
	type_name string
	changed   bool
}

pub fn (mut self Doc) newid() int {
	self.lastid += 1
	return self.lastid
}

pub fn (mut self Doc) last() !Element {
	if self.children.len == 0 {
		return error('doc has no children')
	}

	return self.children.last()
}

pub fn (mut self Doc) delete_last() ! {
	if self.children.len == 0 {
		return error('doc has no children')
	}

	self.children.delete_last()
}

// add a css or script link to a document
//  url: is source where the data comes from, can be CDN or local link
//  path: can be relative or absolute path to the info
// 	bookname, if in memory in a book
//  chaptername, if in memory in a book
//	filename string, if in memory in a book
//  cat, is .css or .script
pub fn (mut self Doc) pre_add(arg HtmlSource) string {
	return ''
}

@[param]
pub struct HtmlSource {
pub mut:
	url         string
	path        string
	bookname    string
	chaptername string
	filename    string
	cat         HtmlSourceCat
}

enum HtmlSourceCat {
	css
	script
}

@[params]
pub struct DocNewArgs {
	ElementNewArgs
pub mut:
	gid smartid.GID
	pre []HtmlSource
}

pub fn doc_new(args DocNewArgs) !Doc {
	mut d := Doc{
		gid: args.gid
		pre: args.pre
	}
	return d
}

pub fn (self Doc) actions() []actionparser.Action {
	mut out := []actionparser.Action{}
	for element in self.children {
		if element is Action {
			out << element.action
		}

		out << element.actions()
	}
	return out
}
