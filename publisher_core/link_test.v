import crystallib.publisher_core

fn test_link1() {
	text := ' ![ some text    ]( http://something.com/?hi&yo  )'
	r1 := publisher.link_parser(text)
	assert r1.links[0].original_get() == '![some text](http://something.com/?hi&yo)'
}

fn test_link2() {
	text := ' ![ some text    ]( wiki.md  )'
	r1 := publisher.link_parser(text)
	text2 := r1.links[0].original_get()
	assert text2 == '![some text](wiki.md)'
}

fn test_link3() {
	text := ' ![ some text    ]( test:wiki.md  )'
	r1 := publisher.link_parser(text)
	text2 := r1.links[0].original_get()
	assert text2 == '![some text](test:wiki.md)'
}
