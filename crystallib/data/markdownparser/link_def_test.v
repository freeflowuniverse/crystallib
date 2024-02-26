module markdownparser

import freeflowuniverse.crystallib.data.markdownparser.elements

fn test_def1() {
	mut mydoc := new(content: ' - *TESTDEF sometext')!

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 3

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[1] is elements.Def
	assert paragraph.children[2] is elements.Text

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content=="- "
	assert paragraph.children[1].content=="*TESTDEF"
	assert paragraph.children[2].content==" sometext"

}


fn test_def2() {
	mut mydoc := new(content: ' - *TeSTDEF sometext')!

	println(mydoc)

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Text

	assert paragraph.children[0].content=="- *TeSTDEF sometext"

}


fn test_def3() {
	mut mydoc := new(content: ' - *TEST_DEF sometext')!


	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 3

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[1] is elements.Def
	assert paragraph.children[2] is elements.Text

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content=="- "
	assert paragraph.children[1].content=="*TEST_DEF"
	assert paragraph.children[2].content==" sometext"

}

fn test_def4() {
	mut mydoc := new(content: ' - *TEST_DEF')!

	// println(mydoc)
	// if true{
	// 	panic("s")
	// }

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 2

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[1] is elements.Def

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content=="- "
	assert paragraph.children[1].content=="*TEST_DEF"

}


fn test_def5() {
	mut mydoc := new(content: '*TEST_DEF')!

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Def

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content=="*TEST_DEF"

}

fn test_def6() {
	mut mydoc := new(content: '

## title does not support defs

*TF_DEF
*TFDEF

- *TF_DEF
- *TFDEF


')!

	assert mydoc.children.len == 3

	paragraph := mydoc.children[2]
	// println(paragraph.children)
	assert paragraph.children.len == 7

	assert paragraph.children[6] is elements.Def

	// mydef := paragraph.children[1]
	assert paragraph.children[6].content=="*TFDEF"

	assert mydoc.defpointers().len==4

}




