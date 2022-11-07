module markdowndocs

import os

const testpath = os.dir(@FILE) + '/testdata'

fn test_1() {
	mut parser := get('$markdowndocs.testpath/test.md') or { panic('cannot parse,$err') }
	correct_doc := '**** Header 1: this is a test
**** Paragraph
    - [this is link](something.md)
    - ![this is link2](something.jpg)
    

**** Header 2: ts
**** Paragraph
    ![this is link2](something.jpg)'
	// panic("yo: ${parser.doc.items[0]}")
	assert typeof(parser.doc.items[0]) == 'markdowndocs.Header'
	header_item := parser.doc.items[0] as Header
	assert header_item.content == 'this is a test'
	assert header_item.depth == 1
}
