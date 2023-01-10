module markdowndocs

import os
import pathlib


// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES
fn doc_parse(path string) ! {
	path2 = pathlib.get_file(path, false)!
	mut doc:=Doc{path:path2}
	mut parser:=parser_new(path)!
	
	// no need to process files which are not at least 2 chars
	for {
		mut llast := doc.items.last()
		if parser.eof() {
			break
		}
		// go out of loop if end of file
		line := parser.line_current()
		// println("line ($parser.state()): '$line'")	

		if mut llast is Comment {
			if llast.prefix == .short {
				if line.trim_space().starts_with('//') {
					llast.content += line.all_after_first('//') + '\n'
					parser.next()
					continue
				}
				doc.items << DocStart{} // make sure we restart from scratch because is not comment
			} else {
				if line.trim_space().ends_with('-->') {
					llast.content += line.all_before_last('-->') + '\n'
					parser.next_start()
				} else {
					llast.content += line + '\n'
					parser.next()
				}
				continue
			}
		}

		if mut llast is Action {
			if line.starts_with(' ') || line.starts_with('\t') {
				// starts with tab or space, means block continues for action
				llast.content += '${line}\n'
			} else {
				doc.items << DocStart{}
			}
			parser.next()
			continue
		}

		if mut llast is CodeBlock {
			if line.starts_with('```') || line.starts_with('"""') || line.starts_with("'''") {
				doc.items << DocStart{}
			} else {
				llast.content += '${line}\n'
			}
			parser.next()
			continue
		}

		if parser.atstart  {
			if line.starts_with('!!') {
				doc.items << Action{
					content: line.all_after_first('!!')

				}
				parser.next()
				continue
			}

			// find codeblock or actions
			if line.starts_with('```') || line.starts_with('"""') || line.starts_with("'''") {
				doc.items << CodeBlock{
					category: line.substr(3, line.len).to_lower().trim_space()

				}
				parser.next()
				continue
			}

			// process headers
			if line.starts_with('######') {
				parser.error_add('header should be max 5 deep')
				parser.next_start()
				continue
			}
			if line.starts_with('#####') {
				doc.items << Header{
					content: line.all_after_first('#####').trim_space()
					depth: 5

				}
				parser.next_start()
				continue
			}
			if line.starts_with('####') {
				doc.items << Header{
					content: line.all_after_first('####').trim_space()
					depth: 4

				}
				parser.next_start()
				continue
			}
			if line.starts_with('###') {
				doc.items << Header{
					content: line.all_after_first('###').trim_space()
					depth: 3

				}
				parser.next_start()
				continue
			}
			if line.starts_with('##') {
				doc.items << Header{
					content: line.all_after_first('##').trim_space()
					depth: 2

				}
				parser.next_start()
				continue
			}
			if line.starts_with('#') {
				doc.items << Header{
					content: line.all_after_first('#').trim_space()
					depth: 1

				}
				parser.next_start()
				continue
			}

			if line.trim_space().starts_with('//') {
				doc.items << Comment{
					content: line.all_after_first('//').trim_space() + '\n'
					prefix: .short

				}
				parser.next()
				continue
			}
			if line.trim_space().starts_with('<!--') {
				doc.items << Comment{
					content: line.all_after_first('<!--').trim_space() + '\n'
					prefix: .multi

				}
				parser.next()
				continue
			}
		}

		if parser.state_check('paragraph') {
			mut lastitem:=doc.items.last()
			if mut lastitem is Paragraph {
				lastitem.content += line + '\n'
			}
		} else {
			doc.items << Paragraph{
				content: line

			}
		}

		parser.next()
	}

	doc.process()!
}




















// // walk backwards over the objects, if equal with what we have we keep on walking back
// // if we find one which is same type as specified will return
// fn (mut parser Parser) item_get_previous(tocheck_ string, ignore_ []string) &DocItem {
// 	mut ignore := ignore_.clone()
// 	mut itemnr := doc.items.len - 1
// 	mut itemname_start := doc.items[itemnr].type_name().all_after_last('.').to_lower()
// 	tocheck := tocheck_.to_lower().trim_space()
// 	// walk backwards till previous state is not the current
// 	// the original itemname
// 	// print(" .. previous $tocheck $ignore")
// 	if itemname_start == tocheck {
// 		// print(" *R0.$itemname_start\n")
// 		return &doc.items[itemnr]
// 	}
// 	for {
// 		mut itemname_current := doc.items[itemnr].type_name().all_after_last('.').to_lower()
// 		if itemnr == 0 {
// 			// print(" *B.$itemname_current")
// 			break
// 		}
// 		if itemname_current in ignore {
// 			itemnr -= 1
// 			// print(" *I.$itemname_current")
// 			continue
// 		}
// 		if itemname_current == tocheck {
// 			// print(" *R.$itemname_current\n")
// 			return &doc.items[itemnr]
// 		}
// 		// print(" *B.$itemname_current")
// 		break
// 	}
// 	// print(" *NO\n")
// 	return &Doc{}
// }

// // go further over lines, see if we can find one which has one of the to_find items in but we didn't get tostop item before
// fn (mut parser Parser) look_forward_find(tofind []string, tostop []string) bool {
// 	mut found := false
// 	for line in parser.lines[parser.linenr + 1..parser.lines.len] {
// 		// println(" +++ " +line)
// 		for item in tostop {
// 			if line.trim_space().starts_with(item) {
// 				// println("found:$found")
// 				return found
// 			}
// 		}
// 		for item2 in tofind {
// 			if line.trim_space().starts_with(item2) {
// 				found = true
// 			}
// 		}
// 	}
// 	// println("NOTFOUND")
// 	return false
// }
