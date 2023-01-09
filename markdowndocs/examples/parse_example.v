module main

import freeflowuniverse.crystallib.markdowndocs
import os

const testpath = os.dir(@FILE) + '/content'

fn do() ! {
	mut doc := markdowndocs.get('${testpath}/launch.md') or { panic('cannot parse,${err}') }

	mut o := doc.items[1]
	if mut o is markdowndocs.Paragraph {
		eprintln(o.links)
	}

	for mut item in doc.items {
		match mut item {
			markdowndocs.Paragraph { 
				for mut link in item.links{
					link.extra = "SEE IF THERE"
				}
			}
			else {}
		}
	}

	for mut item in doc.items {
		match mut item {
			markdowndocs.Paragraph { 
				for mut link in item.links{
					println(link)
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
