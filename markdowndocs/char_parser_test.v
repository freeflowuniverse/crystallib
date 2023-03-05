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
	println('\n\n\n\n')

	mut txt := '!['
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!
	assert p2 == Paragraph{
		content: '!['
		items: [
			ParagraphItem(Link{
				content: '!['
				cat: .file
				isexternal: false
				include: true
				newtab: false
				moresites: false
				description: ''
				url: ''
				filename: ''
				path: ''
				site: ''
				extra: ''
				state: .ok
				error_msg: ''
			}),
		]
	}
}

fn test_charparser4() {
	println('\n\n\n\n')

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
				cat: .file
				isexternal: false
				include: true
				newtab: false
				moresites: false
				description: ''
				url: ''
				filename: ''
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

fn test_charparser5() {
	println('\n\n\n\n')

	mut txt := '![a](b) '
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!

	assert p2.items.last().content == ' '
}

fn test_charparser6() {
	println('\n\n\n\n')

	mut txt := '![a](b)\n \n'
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!

	// println(p2.items.last())
	assert p2.items.last().content.replace('\n', '\\n') == '\\n \\n'
}

fn test_charparser7() {
	println('\n\n\n\n')

	mut txt := '
- list
![a](b) //comment
sometext
'
	mut p2 := Paragraph{
		content: txt
	}
	p2.parse()!
	println(p2)

	println(p2.items[3])
	assert p2.items[3].content == 'comment'
}

fn test_charparser8() {
	println('\n\n\n\n')

	mut txt := '
- list
![a](b.jpg) //comment
sometext
'
	mut p2 := Paragraph{
		content: txt
	}
	p2.process()!

	println('\n\n+++++\n')
	println(p2)

	println(p2.items[3])
	assert p2.items[3].content == 'comment'

	println('\n\n|||${p2.wiki()}|||')

	assert txt == p2.wiki()
}

// fn test_charparser9() {

// 	println("\n\n\n\n")

// 	mut txt:="
// - list
// ![a](b.jpg)<!--comment1-->
// <!--comment2-->
// sometext
// "
// 	mut p2:=Paragraph{content:txt}
// 	p2.process()!

// 	println("\n\n+++++\n")
// 	println(p2)

// 	// println(p2.items[3])
// 	// assert p2.items[3].content=="comment"

// 	println("\n\n|||${p2.wiki()}|||")

// 	// assert txt==p2.wiki()

// 	if true{panic('s')}

// }
