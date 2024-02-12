module elements

pub fn (mut base DocBase) paragraph_new(content string) &Paragraph {
	mut a := Paragraph{
		content: content
		type_name: 'paragraph'
	}

	base.children << a
	return &a
}

pub fn (mut base DocBase) action_new(content string) &Action {
	mut a := Action{
		content: content
		type_name: 'action'
	}
	base.children << a
	return &a
}

pub fn (mut base DocBase) table_new(content string) &Table {
	mut a := Table{
		content: content
		type_name: 'table'
	}

	base.children << a
	return &a
}

pub fn (mut base DocBase) header_new(content string) &Header {
	mut a := Header{
		content: content
		type_name: 'header'
	}

	base.children << a
	return &a
}

pub fn (mut base DocBase) list_new(content string) &List {
	mut a := List{
		content: content
		type_name: 'list'
	}
	a.process() or { panic(err) }
	base.children << a
	return &a
}

pub fn (mut base DocBase) list_item_new(content string) &ListItem {
	mut a := ListItem{
		content: content
		type_name: 'listitem'
	}
	a.process() or { panic(err) }
	base.children << a
	return &a
}


pub fn (mut base DocBase) text_new(content string) &Text {
	mut a := Text{
		content: content
		type_name: 'text'
	}
	a.trailing_lf = false
	base.children << a
	return &a
}

pub fn (mut base DocBase) comment_new(content string) &Comment {
	mut a := Comment{
		content: content
		type_name: 'comment'
	}

	base.children << a
	return &a
}

pub fn (mut base DocBase) include_new(content string) &Include {
	mut a := Include{
		content: content
		type_name: 'include'
	}

	base.children << a
	return &a
}

pub fn (mut base DocBase) codeblock_new(content string) &Codeblock {
	mut a := Codeblock{
		content: content
		type_name: 'codeblock'
	}

	base.children << a
	return &a
}

pub fn (mut base DocBase) link_new(content string) &Link {
	mut a := Link{
		content: content
		type_name: 'link'
	}
	a.trailing_lf = false
	base.children << a
	return &a
}

pub fn (mut base DocBase) html_new(content string) &Html {
	mut a := Html{
		content: content
		type_name: 'html'
	}

	base.children << a
	return &a
}
