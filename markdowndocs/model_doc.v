module markdowndocs

import pathlib

pub struct Doc {
pub mut:
	content string
	items   []DocItem
	path    pathlib.Path
	pre     []HtmlSource
}

[param]
pub struct HtmlSource {
pub mut:
	url string
	path string
	bookname string
	chaptername string
	filename string
	cat HtmlSourceCat
}

enum HtmlSourceCat{
	css
	script
}


//add a css or script link to a document
//  url: is source where the data comes from, can be CDN or local link
//  path: can be relative or absolute path to the info
// 	bookname, if in memory in a book
//  chaptername, if in memory in a book
//	filename string, if in memory in a book
//  cat, is .css or .script
pub fn (mut doc Doc) pre_add(arg HtmlSource) string {

}


type DocItem = Action | Actions | CodeBlock | Header | Html | Link | Paragraph | Table

pub fn (mut doc Doc) wiki() string {
	mut out := ''
	for mut item in doc.items {
		match mut item {
			Table { out += item.wiki() }
			Action { out += item.wiki() }
			Actions { out += item.wiki() }
			Header { out += item.wiki() }
			Paragraph { out += item.wiki() }
			Html { out += item.wiki() }
			// Comment { out += item.wiki() }
			CodeBlock { out += item.wiki() }
			Link { out += item.wiki() }
		}
	}
	return out
}

pub fn (mut doc Doc) html() string {
	mut out := ''
	for mut item in doc.items {
		match mut item {
			Table { out += item.html() }
			Action { out += item.html() }
			Actions { out += item.html() }
			Header { out += item.html() }
			Paragraph { out += item.html() }
			Html { out += item.html() }
			// Comment { out += item.html() }
			CodeBlock { out += item.html() }
			Link { out += item.html() }
		}
	}
	return out
}

pub fn (mut doc Doc) save_wiki() ! {
	doc.path.write(doc.wiki())!
}

// fn (mut doc Doc) last_item_name() string {
// 	return parser.doc.items.last().type_name().all_after_last('.').to_lower()
// }

// // if state is this name will return true
// fn (mut doc Doc) last_item_name_check(tocheck string) bool {
// 	if doc.last_item_name() == tocheck.to_lower().trim_space() {
// 		return true
// 	}
// 	return false
// }
