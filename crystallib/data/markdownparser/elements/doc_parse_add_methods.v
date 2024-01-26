module elements

@[params]
pub struct ElementNewArgs {
pub mut:
	content string
	parent  ?ElementRef
}

pub struct ElementRef {
pub mut:
	ref Element
}


fn set_children(mut doc Doc, element Element, args ?ElementRef) {
	if mut parent := args {
		parent.ref.children << element
	} else {
		doc.children << element
	}
}


pub fn (mut doc Doc) paragraph_new(args ElementNewArgs) &Paragraph {
	mut a := Paragraph{
		content: args.content
		type_name: 'paragraph'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) action_new(args ElementNewArgs) &Action {
	mut a := Action{
		content: args.content
		type_name: 'action'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) table_new(args ElementNewArgs) &Table {
	mut a := Table{
		content: args.content
		type_name: 'table'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) header_new(args ElementNewArgs) &Header {
	mut a := Header{
		content: args.content
		type_name: 'header'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) text_new(args ElementNewArgs) &Text {
	mut a := Text{
		content: args.content
		type_name: 'text'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) comment_new(args ElementNewArgs) &Comment {
	mut a := Comment{
		content: args.content
		type_name: 'comment'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) include_new(args ElementNewArgs) &Include {
	mut a := Include{
		content: args.content
		type_name: 'include'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) codeblock_new(args ElementNewArgs) &Codeblock {
	mut a := Codeblock{
		content: args.content
		type_name: 'codeblock'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) link_new(args ElementNewArgs) &Link {
	mut a := Link{
		content: args.content
		type_name: 'link'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}


pub fn (mut doc Doc) html_new(args ElementNewArgs) &Html {
	mut a := Html{
		content: args.content
		type_name: 'html'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}
