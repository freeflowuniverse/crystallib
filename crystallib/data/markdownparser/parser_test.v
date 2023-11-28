module markdownparser

fn test_output() {
	doc1 := new(
		path: '/home/mariocs/cs/crystallib/examples/data/markdownparser/test.md'
	)!
	content1 := doc1.markdown()

	doc2 := new(content: content1)!
	content2 := doc2.markdown()

	assert content1 == content2
}
