module elements

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn (mut para Paragraph) parse() ! {
	mut parser := parser_char_new_text(para.content.trim_space())

	text_new(parents:[&para]) //the initial one

	mut potential_link := false

	for {
		if parser.eof() {
			break
		}

		mut llast := para.elements.last()
		mut char_ := parser.char_current()

		// check for comments end
		if mut llast is Comment {
			if char_ == '\n' {
				if llast.singleline {
					// means we are at end of line of a single line comment
					text_new(parents:[&para])
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
				text_new(parents:[&para])
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
					para.elements.delete_last() // remove the link
					text_new(content:c,parents:[&para])
					llast = para.elements.last() // fetch last again
					llast.content += char_ // need to add current content
					para.elements << Text{}
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
				text_new(parents:[&para])
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
						comment_new(parents:[&para])
						mut llast2 := para.elements.last()
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
						para.elements << link_new(content:totry, parents:[&para])
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

	//now we need to remove all empty text elements, doesn' seem to be the most efficient code?

	mut toremovelist := []int{}
	mut counter := 0
	for mut element in para.elements {
		match mut element {
			Text {
				if element.content == '' {
					toremovelist << counter
				}
			}
			else{}
		}
		counter += 1
	}
	for toremove in toremovelist.reverse() {
		para.elements.delete(toremove)
	}


}