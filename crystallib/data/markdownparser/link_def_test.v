module markdownparser

import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.ui.console

fn test_empty() {
	mut mydoc := new(content: '')!

	// console.print_debug(mydoc)
	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 0
	assert paragraph.markdown()! == ''
}

fn test_empty2() {
	mut mydoc := new(content: ' ')!

	// console.print_debug(mydoc)
	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Text
	// console.print_debug("TEXT:'${paragraph.children[0].content}'")
	assert paragraph.children[0].markdown()! == ' '
}

fn test_def1() {
	mut mydoc := new(content: ' *TESTDEF sometext')!

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 3

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[1] is elements.Def
	assert paragraph.children[2] is elements.Text

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content == ' '
	assert paragraph.children[1].content == '*TESTDEF'
	assert paragraph.children[2].content == ' sometext'
}

fn test_def2() {
	mut mydoc := new(content: ' *TeSTDEF sometext')!

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Text

	assert paragraph.children[0].content == ' *TeSTDEF sometext'
}

fn test_def3() {
	mut mydoc := new(content: ' *TEST_DEF sometext\n ')!

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 3

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[1] is elements.Def
	assert paragraph.children[2] is elements.Text

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content == ' '
	assert paragraph.children[1].content == '*TEST_DEF'
	assert paragraph.children[2].content == ' sometext\n '
}

fn test_def4() {
	mut mydoc := new(content: ' *TEST_DEF')!

	// console.print_debug(mydoc)
	// if true{
	// 	panic("s")
	// }

	assert mydoc.children.len == 1

	// list := mydoc.children[1]
	paragraph := mydoc.children[0]
	assert paragraph.children.len == 2

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[1] is elements.Def

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content == ' '
	assert paragraph.children[1].content == '*TEST_DEF'
}

fn test_def5() {
	mut mydoc := new(content: '*TEST_DEF')!

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Def

	// mydef := paragraph.children[1]
	assert paragraph.children[0].content == '*TEST_DEF'
}

fn test_def6() {
	mut mydoc := new(
		content: '

## title does not support defs

*TF_DEF
*TFDEF

- *TF_DEF
- *TFDEF


'
	)!
	// console.print_debug(mydoc.children)
	assert mydoc.children.len == 5

	paragraph := mydoc.children[2]
	// console.print_debug(paragraph.children)
	assert paragraph.children.len == 5

	assert paragraph.children[3] is elements.Def
	assert paragraph.children[3].content == '*TFDEF'

	assert mydoc.defpointers().len == 4
}

fn test_def7() {
	mut mydoc := new(content: '**TEST_DEF*')!

	// console.print_debug(mydoc)

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Text
	assert paragraph.children[0].content == '**TEST_DEF*'
}

fn test_def8() {
	mut mydoc := new(content: '**TEST_DEF* ')!

	// console.print_debug(mydoc)

	assert mydoc.children.len == 1

	paragraph := mydoc.children[0]
	assert paragraph.children.len == 1

	assert paragraph.children[0] is elements.Text
	// console.print_debug("TEXT:'${paragraph.children[0].markdown()!}'")
	assert paragraph.children[0].markdown()! == '**TEST_DEF* '
}
