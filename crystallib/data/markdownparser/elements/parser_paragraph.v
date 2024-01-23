module elements

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn (mut paragraph Paragraph) paragraph_parse() ! {
	mut parser := parser_char_new_text(paragraph.content.trim_space())

	// mut d := para.doc or { panic('no doc') }
	paragraph.text_new('') // the initial one

	mut potential_link := false

	for {
		if parser.eof() {
			break
		}

		mut llast := paragraph.children.last()
		mut char_ := parser.char_current()

		// check for comments end
		if mut llast is Comment {
			if char_ == '\n' {
				if llast.singleline {
					// means we are at end of line of a single line comment
					paragraph.text_new('\n')
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
				paragraph.text_new('')
				parser.next()
				char_ = ''
				continue
			}
		}

		if mut llast is Link {
			if char_ == ']' {
				if !parser.text_next_is('(', 1) {
					// means is not link, need to convert link to normal text
					mut c := llast.content
					paragraph.children.delete_last() // remove the link
					paragraph.text_new('')
					llast = paragraph.children.last() // fetch last again
					llast.content += c + char_ // need to add current content
					parser.next()
					// println("\n!!!!!!!!!!!!!!!!!!!!!\n")
					char_ = ''
					continue
				}
				potential_link = true
			}
			if char_ == ')' && potential_link {
				// end of link
				llast.content += char_ // need to add current content
				paragraph.text_new('')
				parser.next()
				char_ = ''
				potential_link = false
				continue
			}
		}

		if mut llast is Text {
			if char_ != '' {
				// check for comments start
				for totry in ['<!--', '//'] {
					if parser.text_next_is(totry, 0) {
						// we are now in comment
						paragraph.comment_new('')
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
			}
			if char_ != '' {
				// try to find link
				for totry in ['![', '['] {
					if parser.text_next_is(totry, 0) {
						paragraph.link_new(totry)
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
}
