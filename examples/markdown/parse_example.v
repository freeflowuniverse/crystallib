module main

import freeflowuniverse.crystallib.markdowndocs
import os
import markdown

const testpath = os.dir(@FILE) + '/content'

// fn do() !{
// 	c:=os.read_file('${testpath}/launch.md') or { panic('cannot parse,${err}') }
// 	mut m:=markdown.to_md(c)!
// 	println(m)
	
// }

fn do2() ! {
	mut doc := markdowndocs.get('${testpath}/launch.md') or { panic('cannot parse,${err}') }
	// println(doc)
	mut o := doc.items[1]
    // println(o)
	// println(doc.items[0].content)

	// if mut o is markdowndocs.Paragraph {
	// 	eprintln(o.items)
	// }

	println("\n\n\n")

	for mut item in doc.items {
		println(item)
		match mut item {
			markdowndocs.Paragraph {
				for mut item2 in item.items{
					if mut item2 is markdowndocs.Link {
						// println(item2)
					}
				}
			}
			else {}
		}
	}

	println("==================")
	println(doc.wiki())

}

fn main() {
	do2() or { panic("ERROR:$err") }
}