module parsers

import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.data.actionparser
// import regex

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT RELIALITIES
pub fn parse_doc(mut doc elements.Doc) ! {
	mut parser := parser_line_new(mut doc)!
	// re_header_row := regex.regex_opt('^:?-+:?$') or { return error("regex doesn't work") }

	for {
		if parser.eof() {
			// println("---end")
			break
		}
		// go out of loop if end of file
		mut line := parser.line_current()
		line = line.replace('\t', '    ')
		trimmed_line := line.trim_space()

		mut llast := parser.lastitem()

		if mut llast is elements.Table {
			if trimmed_line.starts_with('|') && trimmed_line.ends_with('|') {
				llast.content += '${line}\n'
				parser.next()
				continue
			}

			parser.append_paragraph()
			continue
		}

		if mut llast is elements.Action {
			if line.starts_with(' ') {
				// starts with tab or space, means block continues for action
				llast.content += '${line}\n'
				parser.next()
				continue
			}

			parser.append_paragraph()
			continue
		}

		if mut llast is elements.Html {
			if line.trim_space().to_lower().starts_with('</html>') {
				parser.next_start()
				continue
			}
		}

		if mut llast is elements.CodeBlock {
			if trimmed_line == '```' {
				parser.next_start()
				continue
			}

			llast.content += '${line}\n'
			parser.next()
			continue
		}

		if mut llast is elements.Paragraph {
			// TODO: support tables

			// if line.starts_with('|') && line.ends_with('|') {
			// 	//TODO: tab;e doesn't seem to be on right place, should be done on paragraph level
			// 	if !parser.next_is_eof() {
			// 		header := line.trim('|').split('|').map(it.trim(' \t'))
			// 		line2 := parser.line_next()
			// 		second_row := line2.trim('|').split('|').map(it.trim(' \t')).filter(re_header_row.matches_string(it))
			// 		if header.len == second_row.len {
			// 			// from now on we know it is a valid map
			// 			mut alignments := []Alignment{}
			// 			for cell in second_row {
			// 				mut alignment := Alignment.left
			// 				if cell[0] == 58 { // == ":"
			// 					if cell[cell.len - 1] == 58 { // == ":"
			// 						alignment = Alignment.center
			// 					}
			// 				} else if cell[cell.len - 1] == 58 { // == ":"
			// 					alignment = Alignment.right
			// 				}
			// 				alignments << alignment
			// 			}
			// 			doc.elements << elements.Table{
			// 				content: '${line}\n${line2}\n'
			// 				num_columns: header.len
			// 				header: header
			// 				alignments: alignments
			// 			}
			// 			parser.next()
			// 			parser.next()
			// 			continue
			// 		}
			// 	}
			// }
			// parse includes
			if line.starts_with('!!include ') {
				content := line.all_after_first('!!include ').trim_space()
				doc.elements << elements.include_new(content: content)
				parser.next_start()
				continue
			}
			// parse action
			if line.starts_with('!') {
				doc.elements << elements.action_new(content: line, parents: [&doc])
				parser.next()
				continue
			}

			// find codeblock
			if line.starts_with('```') {
				doc.elements << elements.codeblock_new(
					category: line.substr(3, line.len).to_lower().trim_space()
					parents: [&doc]
				)
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
						parser.next_start()
						continue
					}
					doc.elements << elements.Header{
						content: line.all_after_first(line[..d]).trim_space()
						depth: d
					}
					parser.next_start()
					continue
				}
			}

			if trimmed_line.starts_with('|') && trimmed_line.ends_with('|') {
				doc.elements << elements.table_new(content: '${line}\n')
				parser.next()
				continue
			}

			if trimmed_line.to_lower().starts_with('<html>') {
				doc.elements << elements.html_new()
				parser.next()
				continue
			}
		}

		match mut llast {
			elements.Paragraph, elements.Html, elements.Include, elements.CodeBlock {
				if parser.endlf == false && parser.next_is_eof() {
					llast.content += line
				} else {
					llast.content += line + '\n'
				}
			}
			else {
				println(line)
				println(llast)
				panic('parser error, means we got element which is not supported')
			}
		}

		parser.next()
	}

	// parse action elements
	for mut element in doc.elements {
		if mut element is elements.Action {
			element.action = actionparser.parse(text: element.content)!
		}
	}
}
