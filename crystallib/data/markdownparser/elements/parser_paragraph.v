module elements

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// adds the found links, text, comments to the paragraph
fn paragraph_parse(mut d Doc, mut paragraph Paragraph) ! {
	para := paragraph
	mut parser := parser_char_new_text(para.content.trim_space())

	// mut d := para.doc or { panic('no doc') }
	d.text_new(
		parent: ElementRef{
			ref: paragraph
		}
	) // the initial one

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
					d.text_new(
						parent: ElementRef{
							ref: paragraph
						}
						content: '\n'
					)
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
				d.text_new(
					parent: ElementRef{
						ref: paragraph
					}
				)
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
					d.text_new(
						parent: ElementRef{
							ref: paragraph
						}
					)
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
				d.text_new(
					parent: ElementRef{
						ref: paragraph
					}
				)
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
						d.comment_new(
							parent: ElementRef{
								ref: paragraph
							}
						)
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
						d.link_new(
							content: totry
							parent: ElementRef{
								ref: paragraph
							}
						)
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
