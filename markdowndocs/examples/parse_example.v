module main

import freeflowuniverse.crystallib.markdowndocs
import os

const testpath = os.dir(@FILE) + '/content'

fn do() ! {
	mut doc := markdowndocs.get('${testpath}/launch.md') or { panic('cannot parse,${err}') }
	println(doc)
	mut o := doc.items[1]
	println(doc.items[0].content)

	if mut o is markdowndocs.Paragraph {
		eprintln(o.items)
	}

	for mut item in doc.items {
		match mut item {
			markdowndocs.Paragraph { 
				for mut item_ in item.items{
					if mut item_ is markdowndocs.Link {
						item_.extra = "SEE IF THERE"
					}
				}
			}
			else {}
		}
	}

	for mut item in doc.items {
		match mut item {
			markdowndocs.Paragraph { 
				for mut item_ in item.items{
					if mut item_ is markdowndocs.Link {
						item_.extra = "SEE IF THERE"
					}
				}
				println(item)
			}
			else {}
		}
	}	
	println("==================")
	println(doc.wiki())

}

fn main() {
	do() or { panic(err) }
}
