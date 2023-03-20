module markdowndocs

fn test_charparser1() {
	mut txt := ''
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!
	assert p2 == Paragraph{
		content: ''
		items: []
		changed: false
	}
}

fn test_charparser2() {
	mut txt := 'abc'

	mut p := parser_char_new_text(txt)

	p.forward(0)
	assert p.char_current() == 'a'

	p.forward(1)
	assert p.char_current() == 'b'

	p.forward(1)
	assert p.char_current() == 'c'

	p.charnr = 1
	assert p.char_current() == 'b'

	assert p.char_next() == 'c'
	assert p.char_prev() == 'a'

	assert p.text_next_is('c', 1)
	assert p.text_next_is('c', 0) == false
	assert p.text_next_is('b', 0) == true

	assert p.text_next_is('bc', 0) == true
	assert p.text_next_is('bcs', 0) == false
	assert p.text_next_is('ab', 0) == false

	p.charnr = 0
	assert p.text_next_is('abc', 0) == true
	assert p.text_next_is('abc', 1) == false
	assert p.text_next_is('bc', 1) == true
	assert p.text_next_is('c', 2) == true
}

fn test_charparser3() {
	mut txt := '!['
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!
	// TODO decide what to do in this case
	// assert p2 == Paragraph {
	// 	content: '!['
	// 	items: [
	// 		ParagraphItem(Link {
	// 			content: '!['
	// 			cat: .page
	// 			isexternal: false
	// 			include: true
	// 			newtab: false
	// 			moresites: false
	// 			description: ''
	// 			url: ''
	// 			filename: ''
	// 			path: ''
	// 			site: ''
	// 			extra: ''
	// 			state: .ok
	// 			error_msg: ''
	// 		}),
	// 	]
	// }
}

fn test_charparser_link() {
	mut txt := '![a](b)'
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!
	assert p2 == Paragraph{
		content: '![a](b)'
		items: [
			ParagraphItem(Link{
				content: '![a](b)'
				cat: .page
				isexternal: false
				include: false
				newtab: false
				moresites: false
				description: 'a'
				url: 'b'
				filename: 'b.md'
				path: ''
				site: ''
				extra: ''
				state: .ok
				error_msg: ''
			}),
		]
		changed: false
	}
}

fn test_charparser_link_ignore_trailing_spaces() {
	mut txt := '![a](b) '
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!

	assert p2.items.len == 1
	assert p2.items.last().content == '![a](b)'
}

fn test_charparser_link_ignore_trailing_newlines() {
	mut txt := '![a](b)\n \n'
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!

	assert p2.items.len == 1
	assert p2.items.last().content == '![a](b)'
}

fn test_charparser_link_comment_text() {
	mut txt := '
- list
![a](b.jpg) //comment
sometext
'
	mut p2 := Paragraph{
		content: txt
	}
	p2.process()!

	assert p2.items.len == 5
	assert p2.items[0] is Text
	assert p2.items[0].content == '- list\n'
	assert p2.items[1] is Link
	item_1 := p2.items[1] as Link
	assert item_1.cat == .image
	assert item_1.filename == 'b.jpg'
	assert item_1.description == 'a'
	assert p2.items[2] is Text
	assert p2.items[2].content == ' '
	assert p2.items[3] is Comment
	item_3 := p2.items[3] as Comment
	assert item_3.content == 'comment'
	assert item_3.singleline == true
	assert p2.items[4] is Text
	assert p2.items[4].content == 'sometext'

	assert '${txt.trim_space()}\n\n' == p2.wiki()
}

fn test_charparser_link_multilinecomment_text() {
	mut txt := '
- list
![a](b.jpg)<!--comment1-->
<!--comment2-->
sometext
'
	mut p2 := Paragraph{
		content: txt
	}
	p2.process()!

	assert p2.items.len == 6
	assert p2.items[0] is Text
	assert p2.items[0].content == '- list\n'
	assert p2.items[1] is Link
	item_1 := p2.items[1] as Link
	assert item_1.cat == .image
	assert item_1.filename == 'b.jpg'
	assert item_1.description == 'a'
	assert p2.items[2] is Comment
	item_2 := p2.items[2] as Comment
	assert item_2.content == 'comment1'
	assert item_2.singleline == false
	assert p2.items[3] is Text
	assert p2.items[3].content == '\n'
	assert p2.items[4] is Comment
	item_4 := p2.items[4] as Comment
	assert item_4.content == 'comment2'
	assert item_4.singleline == false
	assert p2.items[5] is Text
	assert p2.items[5].content == '\nsometext'

	assert '${txt.trim_space()}\n\n' == p2.wiki()
}
