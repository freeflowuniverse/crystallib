module parsers

import freeflowuniverse.crystallib.data.markdownparser.elements

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES
pub fn parse_doc(mut doc elements.Doc) ! {
	mut parser := parser_line_new(mut doc)!
	doc.type_name = "doc"
	for {
		if parser.eof() {
			// go out of loop if end of file
			// println('--- end')
			break
		}

		mut line := parser.line_current()
		trimmed_line := line.trim_space()

		mut llast := parser.lastitem()!

		// console.print_header('- line: ${llast.type_name} ${line}')

		if mut llast is elements.Table {
			if trimmed_line != '' {
				llast.content += '${line}\n'
				parser.next()
				continue
			}
			parser.next_start()!
			continue
		}

		if mut llast is elements.Action {
			if line.starts_with(' ') {
				// starts with tab or space, means block continues for action
				llast.content += '${line}\n'
				parser.next()
				continue
			}

			parser.ensure_last_is_paragraph()!
			continue
		}

		if mut llast is elements.Html {
			if line.trim_space().to_lower().starts_with('</html>') {
				parser.next_start()!
				continue
			}
			llast.content += '${line}\n'
			parser.next()
			continue
		}

		if mut llast is elements.Codeblock {
			if trimmed_line == '```' || trimmed_line == "'''" {
				parser.next_start()!
				continue
			}
			llast.content += '${line}\n'
			parser.next()
			continue
		}

		if mut llast is elements.Paragraph || mut llast is elements.List{

			if line.len > 0 && line.trim_space().starts_with("- "){
				mut e:=doc.list_new(line)
				e.parent=&doc
				if mut llast is elements.List {
					if e.depth>llast.depth{
						e.depth=llast.depth+1
					}else if e.depth<llast.depth && e.depth!=0{
						e.depth=llast.depth-1
					}
				}
				parser.next()
				continue				
			}

			if mut llast is elements.List{
				parser.ensure_last_is_paragraph()!
				continue
			}

			if line.starts_with('!!include ') {
				content := line.all_after_first('!!include ').trim_space()
				doc.include_new(content).parent=&doc
				parser.next_start()!
				continue
			}
			// parse action
			if line.starts_with('!!') {
				doc.action_new(line).parent=&doc
				parser.next()
				continue
			}

			// find codeblock
			if line.starts_with('```') || line.starts_with("'''") {
				mut e := doc.codeblock_new('')
				e.parent=&doc
				e.category = line.substr(3, line.len).to_lower().trim_space()
				parser.next()
				continue
			}

			// process headers (# is 35)
			if line.len > 0 && line[0] == 35 {
				mut d := 0
				for d < line.len && line[d] == 35 {
					d += 1
				}
				if d < line.len && line[d] == 32 {
					if d >= 6 {
						parser.error_add('header should be max 5 deep')
						parser.next_start()!
						continue
					}
					mut e := doc.header_new(line.all_after_first(line[..d]).trim_space())
					e.parent=&doc
					e.depth = d
					parser.next_start()!
					continue
				}
				parser.next()
				continue
			}


			if trimmed_line.starts_with('|') && trimmed_line.ends_with('|') {
				doc.table_new('${line}\n').parent=&doc
				parser.next()
				continue
			}

			if trimmed_line.to_lower().starts_with('<html>') {
				doc.html_new(trimmed_line.after('<html>')).parent=&doc	
				parser.next()
				continue
			}

			if trimmed_line.starts_with('<!--') && trimmed_line.ends_with('-->') {
				mut comment := trimmed_line.all_after_first('<!--')
				comment = comment.all_before('-->')
				doc.comment_new(comment).parent=&doc
				parser.next_start()!
				continue
			}
		}
			
		match mut llast {
			elements.List {
			}
			elements.Paragraph {
				if parser.endlf == false && parser.next_is_eof() {
					llast.content += line
				} else {
					llast.content += line + '\n'
				}
			}
			else {
				println(llast)
				panic('parser error, means we got element which is not supported')
			}
		}
		
		parser.next()
	}
	doc.process()!
}
