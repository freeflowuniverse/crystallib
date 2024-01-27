module elements

import freeflowuniverse.crystallib.data.paramsparser



@[params]
pub struct ElementNewArgs {
pub mut:
	content string
	// parent  ?ElementRef
}

// pub struct ElementRef {
// pub mut:
// 	ref Element
// }


// fn set_children(mut doc Doc, element Element, args ?ElementRef) {
// 	if mut parent := args {
// 		parent.ref.children << element
// 	} else {
// 		doc.children << element
// 	}
// }


pub fn (mut doc Element) paragraph_new(args ElementNewArgs) &Paragraph {
	mut a := Paragraph{
		content: args.content
		type_name: 'paragraph'
		//id: doc.newid()
	}
	doc.children << a
	return &a
}

pub fn (mut doc Doc) action_new(args ElementNewArgs) &Action {
	mut a := Action{
		content: args.content
		type_name: 'action'
		//id: doc.newid()
	}
	doc.children<<a
	return &a
}

pub fn (mut doc Element) table_new(args ElementNewArgs) &Table {
	mut a := Table{
		content: args.content
		type_name: 'table'
		//id: doc.newid()
	}
	doc.children<<a
	return &a
}

pub fn (mut doc Element) header_new(args ElementNewArgs) &Header {
	mut a := Header{
		content: args.content
		type_name: 'header'
		//id: doc.newid()
	}
	doc.children<<a
	return &a
}

pub fn (mut doc Element) text_new(args ElementNewArgs) &Text {
	mut a := Text{
		content: args.content
		type_name: 'text'
		//id: doc.newid()
	}
	doc.children<<a
	return &a
}

pub fn (mut doc Element) include_new(args ElementNewArgs) &Include {
	mut a := Include{
		content: args.content
		type_name: 'include'
		//id: doc.newid()
	}
	doc.children<<a
	return &a
}
