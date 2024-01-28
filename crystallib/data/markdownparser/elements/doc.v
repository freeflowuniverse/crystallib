module elements

// import freeflowuniverse.crystallib.core.smartid

@[heap]
pub struct Doc {
	DocBase
pub mut:
	// gid smartid.GID
	pre []HtmlSource
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
pub mut:
	pre     []HtmlSource
	content string
}

pub fn doc_new(args DocNewArgs) !Doc {
	mut d := Doc{
		pre: args.pre
	}
	return d
}


pub fn (mut self Doc) process() !int {	
	if self.processed {
		return 0
	}
	self.remove_empty_children()
	self.process_base()!
	self.process_children()!
	self.content = "" //because now the content is in children	
	if self.children.len>0{
		mut last := self.children[0] or { panic("bug") }
		last = Paragraph{} //to make sure we start from right base
		mut type_name:=""
		mut type_name_last:=""
		for mut element in self.children {
			type_name=element.type_name().all_after_last(".").to_lower()
			if type_name in ["list"] && type_name == type_name_last{
				last.trailing_lf = false
			}
			// last = element
			type_name_last=type_name
		}
		self.id_set(0)
		self.processed = true
	}
	return 1
}


// pub fn (self Doc) markdown() string {
// 	return ""
// }

// pub fn (self Doc) html() string {
// 	return ""
// }
