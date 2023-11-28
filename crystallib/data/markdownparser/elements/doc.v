module elements

import freeflowuniverse.crystallib.baobab.smartid

@[heap]
pub struct Doc {
	DocBase
pub mut:
	elements  map[int]&DocElement     //   @[skip; str: skip]
	gid smartid.GID
	pre []HtmlSource
	lastid int 
}



pub fn (mut self Doc) newid() int {
	self.lastid+=1
	return self.lastid
}

pub fn (mut self Doc) last() &DocElement {
	return self.elements[self.lastid] or {panic("cant find last")}
}


pub fn (mut self Doc) delete_last() {
	self.elements.delete(self.lastid)
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

