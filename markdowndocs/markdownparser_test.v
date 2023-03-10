module markdowndocs

import os

const testpath = os.dir(@FILE) + '/testdata'

fn test_parsing_using_path() {
	mut doc := new(path:'${markdowndocs.testpath}/test.md') or { panic('cannot parse,${err}') }
	correct_doc := '**** Header 1: this is a test
**** Paragraph
    - [this is link](something.md)
    - ![this is link2](something.jpg)
    

**** Header 2: ts
**** Paragraph
    ![this is link2](something.jpg)'

	assert doc.items[0] is Header
	header_item := doc.items[0] as Header
	assert header_item.content == 'this is a test'
	assert header_item.depth == 1
}
