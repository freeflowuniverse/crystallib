module markdownparser

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn (mut para Paragraph) parse() ! {
	mut parser := parser_char_new_text(para.content.trim_space())

	para.elements << Text{}
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
					para.elements << Text{}
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
				para.elements << Text{}
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
					para.elements << Text{
						content: c
					} // we need to re-add the content
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
				para.elements << Text{}
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
						para.elements << Comment{}
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
						mut l := link_new()
						l.content = totry
						para.elements << l
						parser.forward(totry.len - 1)
						char_ = ''
						break
					}
				}
			}
		}
		llast.content += char_
		// match llast {
		// 	Link{

		// 	}
		// 	Text{

		// 	}
		// 	Comment{

		// 	}

		parser.next()
	}

	mut toremovelist := []int{}
	mut counter := 0
	for mut element in para.elements {
		match mut element {
			Text {
				element.process()!
				if element.content == '' {
					toremovelist << counter
				}
			}
			Link {
				element.process()!
			}
			Comment {
				element.process()!
			}
		}
		counter += 1
	}
	for toremove in toremovelist.reverse() {
		para.elements.delete(toremove)
	}
}
