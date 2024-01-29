module elements

fn test_charparser1() {
	mut txt := ''
	mut p2 := Paragraph{
		content: txt
	}

	p2.paragraph_parse()!
	p2.process_base()!
	assert p2.content == ''
	assert p2.children.len == 0
	assert p2.changed == false
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

	p2.paragraph_parse()!
	p2.process_base()!
	p2.process_children()!
	// TODO decide what to do in this case
	assert p2.content == '!['
	assert p2.children.len == 1
	ln := p2.children[0]
	assert ln is Link
	if ln is Link {
		assert ln.id == 0
		assert ln.processed == true
		assert ln.type_name == 'link'
		assert ln.cat == .page
		assert ln.filename == '![.md'
	}
}

fn test_charparser_link() {
	mut txt := '![a](b)'
	mut p2 := Paragraph{
		content: txt
	}
	mut doc := Doc{}
	p2.paragraph_parse()!
	p2.process_base()!
	p2.process_children()!

	assert p2.children.len == 1

	ln := p2.children[0]
	assert ln is Link
	if ln is Link {
		assert ln.id == 0
		assert ln.type_name == 'link'
		assert ln.content == '![a](b)'
		assert ln.cat == .page
		assert ln.description == 'a'
		assert ln.url == 'b'
		assert ln.filename == 'b.md'
		assert ln.state == .ok
	}
}

fn test_charparser_link_ignore_trailing_spaces() {
	mut txt := '![a](b) '
	mut p2 := Paragraph{
		content: txt
	}
	mut doc := Doc{}
	p2.paragraph_parse()!
	p2.process_base()!
	p2.process_children()!

	assert p2.children.len == 1
	assert p2.children.last().content == '![a](b)'
}

fn test_charparser_link_ignore_trailing_newlines() {
	mut txt := '![a](b)\n \n'
	mut p2 := Paragraph{
		content: txt
	}
	mut doc := Doc{}
	p2.paragraph_parse()!
	p2.process_base()!
	p2.process_children()!

	assert p2.children.len == 1
	assert p2.children.last().content == '![a](b)'
}

fn test_charparser_link_comment_text() {
	mut txt := '
![a](b.jpg) //comment
sometext
'
	mut p2 := Paragraph{
		content: txt
	}

	p2.paragraph_parse()!
	p2.process_base()!
	p2.process_children()!

	assert p2.children.len == 3

	assert p2.children[0] is Link
	item_1 := p2.children[0]
	if item_1 is Link {
		assert item_1.cat == .image
		assert item_1.filename == 'b.jpg'
		assert item_1.description == 'a'
	}

	assert p2.children[1] is Comment
	item_2 := p2.children[1]
	if item_2 is Comment {
		assert item_2.content == 'comment'
	}

	assert p2.children[2] is Text
	assert p2.children[2].content == 'sometext'
}

fn test_charparser_link_multilinecomment_text() {
	mut txt := '![a](b.jpg)<!--comment1-->
<!--comment2-->
sometext'
	mut p2 := Paragraph{
		content: txt
	}
	mut doc := Doc{}
	p2.paragraph_parse()!
	p2.process_base()!
	p2.process_children()!

	assert p2.children.len == 4

	assert p2.children[0] is Link
	item_1 := p2.children[0]
	if item_1 is Link {
		assert item_1.cat == .image
		assert item_1.filename == 'b.jpg'
		assert item_1.description == 'a'
	}

	assert p2.children[1] is Comment
	item_2 := p2.children[1]
	if item_2 is Comment {
		assert item_2.content == 'comment1'
		assert item_2.singleline == false
	}

	assert p2.children[2] is Comment
	item_4 := p2.children[2]
	if item_4 is Comment {
		assert item_4.content == 'comment2'
		assert item_4.singleline == false
	}

	assert p2.children[3] is Text
	assert p2.children[3].content == 'sometext'

	assert txt == p2.markdown()
}
