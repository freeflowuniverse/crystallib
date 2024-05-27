module elements

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn (mut paragraph Paragraph) paragraph_parse() ! {
	mut parser := parser_char_new_text(paragraph.content)

	// mut d := para.doc or { panic('no doc') }
	paragraph.text_new(mut paragraph.parent_doc(), '') // the initial one

	mut potential_link := false
	mut link_in_link := false

	for {
		mut llast := paragraph.children.last()
		mut char_ := parser.char_current()

		// console.print_debug("[[[${char_}]]]")

		// char == '' means end of file
		if mut llast is Def {
			if (char_ == '' || char_ == ' ' || char_ == '\n') && parser.char_prev() != '*' {
				if llast.content.len < 3 {
					paragraph.children.pop()
					mut llast2 := paragraph.children.last()
					if mut llast2 is Text {
						llast2.content += llast.content + char_
					} else {
						paragraph.text_new(mut paragraph.parent_doc(), llast.content + char_)
					}
					parser.next()
					char_ = ''
					continue
				} else {
					// means we did find a def, we can stop
					// console.print_debug(" -- end def")
					paragraph.text_new(mut paragraph.parent_doc(), char_)
					parser.next()
					char_ = ''
					continue
				}
			} else if !(texttools.is_upper_text(char_) || char_ == '_') {
				// this means it wasn't a def, we need to add text
				// console.print_debug(' -- no def: ${char_}')
				paragraph.children.pop()
				// console.print_debug(' -- no def: ${paragraph.children.last()}')
				mut llast2 := paragraph.children.last()
				if mut llast2 is Text {
					llast2.content += llast.content + char_
				} else {
					paragraph.text_new(mut paragraph.parent_doc(), llast.content + char_)
				}
				parser.next()
				char_ = ''
				continue
			}
			// console.print_debug(" -- def: ${char_}")
		}

		if parser.eof() {
			assert char_ == ''
			break
		}

		// check for comments end
		if mut llast is Comment {
			if char_ == '\n' {
				if llast.singleline {
					// means we are at end of line of a single line comment
					paragraph.text_new(mut paragraph.parent_doc(), '\n')
					parser.next()
					char_ = ''
					continue
				} else {
					// now we know for sure comment is not single line
					llast.singleline = false
				}
			}
			if parser.text_next_is('-->', 1) {
				// means is end of comment
				llast.content += char_ // need to add current content
				// need to move forward not to have the 3 next
				parser.forward(3)
				paragraph.text_new(mut paragraph.parent_doc(), '')
				parser.next()
				char_ = ''
				continue
			}
		}

		if mut llast is Link {
			// means there is image in link description, is allowed
			if parser.text_next_is('![', 0) && llast.content == '[' {
				link_in_link = true
			}
			if char_ == ']' {
				if !parser.text_next_is('(', 1) {
					// means is not link, need to convert link to normal text
					if link_in_link {
						link_in_link = false
						continue
					}

					mut c := llast.content
					paragraph.children.delete_last() // remove the link
					paragraph.text_new(mut paragraph.parent_doc(), '')
					llast = paragraph.children.last() // fetch last again
					llast.content += c + char_ // need to add current content
					parser.next()

					char_ = ''
					continue
				}
				potential_link = true
			}
			if char_ == ')' && potential_link {
				// end of link
				if link_in_link {
					// the parsed content was actually the child links in the description
					llast.link_new(mut paragraph.parent_doc(), '${llast.content.trim_string_left('[')})')
					link_in_link = false
					potential_link = false
					continue
				} else {
					llast.content += char_ // need to add current content
					paragraph.text_new(mut paragraph.parent_doc(), '')
					parser.next()
					char_ = ''
					potential_link = false
				}
				continue
			}
		}

		if mut llast is Text {
			if char_ != '' {
				if char_ == '*' {
					paragraph.def_new(mut paragraph.parent_doc(), '*')
					parser.next()
					char_ = ''
					continue
				}
				// check for comments start
				for totry in ['<!--', '//'] {
					// TODO: this is a quick fix for now (https:// is being parsed as comment)
					is_url := llast.content.ends_with(':') && totry == '//'
					if parser.text_next_is(totry, 0) && !is_url {
						// we are now in comment
						paragraph.comment_new(mut paragraph.parent_doc(), '')
						mut llast2 := paragraph.children.last()
						if totry == '//' {
							if mut llast2 is Comment {
								llast2.singleline = true
							}
						}
						parser.forward(totry.len - 1)
						char_ = ''
						break
					}
				}
				// try to find link
				for totry in ['![', '['] {
					if parser.text_next_is(totry, 0) {
						paragraph.link_new(mut paragraph.parent_doc(), totry)
						parser.forward(totry.len - 1)
						char_ = ''
						break
					}
				}
			}
		}
		llast.content += char_
		parser.next()
	}
	paragraph.remove_empty_children()
	// console.print_debug("[[[[[DONE]]]]]")
}
