module elements

type DocElement = Action
	| Codeblock
	| Comment
	| Header
	| Html
	| Include
	| Link
	| Paragraph
	| Table
	| Text

pub fn (mut self DocBase) process_elements() !int {
	for {
		mut changes := 0
		for mut element in self.children() {
			match mut element {
				Html {
					changes += element.process()!
				}
				Paragraph {
					changes += element.process()!
				}
				Action {
					changes += element.process()!
				}
				Table {
					changes += element.process()!
				}
				Header {
					changes += element.process()!
				}
				Text {
					changes += element.process()!
				}
				Comment {
					changes += element.process()!
				}
				Include {
					changes += element.process()!
				}
				Codeblock {
					changes += element.process()!
				}
				Link {
					changes += element.process()!
				}
			}
		}
		if changes == 0 {
			break
		}
	}
	return 0
}

pub fn (mut self DocBase) markdown() string {
	mut out := ''
	for mut element in self.children() {
		match mut element {
			Html { out += element.markdown() }
			Paragraph { out += element.markdown() }
			Action { out += element.markdown() }
			Table { out += element.markdown() }
			Header { out += element.markdown() }
			Text { out += element.markdown() }
			Comment { out += element.markdown() }
			Include { out += element.markdown() }
			Codeblock { out += element.markdown() }
			Link { out += element.markdown() }
		}
	}
	return out
}

pub fn (mut self DocBase) html() string {
	mut out := ''
	for mut element in self.children() {
		match mut element {
			Html { out += element.html() }
			Paragraph { out += element.html() }
			Action { out += element.html() }
			Table { out += element.html() }
			Header { out += element.html() }
			Text { out += element.html() }
			Comment { out += element.html() }
			Include { out += element.html() }
			Codeblock { out += element.html() }
			Link { out += element.html() }
		}
	}
	return out
}

fn (self DocBase) treeview_(prefix string, mut out []string) {
	out << '${prefix}- ${self.type_name:-30} ${self.content.len}'
	for element in self.children() {
		match element {
			Html { element.treeview_(prefix + '  ', mut out) }
			Paragraph { element.treeview_(prefix + '  ', mut out) }
			Action { element.treeview_(prefix + '  ', mut out) }
			Table { element.treeview_(prefix + '  ', mut out) }
			Header { element.treeview_(prefix + '  ', mut out) }
			Text { element.treeview_(prefix + '  ', mut out) }
			Comment { element.treeview_(prefix + '  ', mut out) }
			Include { element.treeview_(prefix + '  ', mut out) }
			Codeblock { element.treeview_(prefix + '  ', mut out) }
			Link { element.treeview_(prefix + '  ', mut out) }
		}
	}
}

pub fn (mut doc Doc) html_new(args ElementNewArgs) &Html {
	mut a := Html{
		content: args.content
		type_name: 'html'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) paragraph_new(args ElementNewArgs) &Paragraph {
	mut a := Paragraph{
		content: args.content
		type_name: 'paragraph'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) action_new(args ElementNewArgs) &Action {
	mut a := Action{
		content: args.content
		type_name: 'action'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) table_new(args ElementNewArgs) &Table {
	mut a := Table{
		content: args.content
		type_name: 'table'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) header_new(args ElementNewArgs) &Header {
	mut a := Header{
		content: args.content
		type_name: 'header'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) text_new(args ElementNewArgs) &Text {
	mut a := Text{
		content: args.content
		type_name: 'text'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) comment_new(args ElementNewArgs) &Comment {
	mut a := Comment{
		content: args.content
		type_name: 'comment'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) include_new(args ElementNewArgs) &Include {
	mut a := Include{
		content: args.content
		type_name: 'include'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) codeblock_new(args ElementNewArgs) &Codeblock {
	mut a := Codeblock{
		content: args.content
		type_name: 'codeblock'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}

pub fn (mut doc Doc) link_new(args ElementNewArgs) &Link {
	mut a := Link{
		content: args.content
		type_name: 'link'
		doc: doc
		id: doc.newid()
		parent: args.parent
	}
	if a.parent > 0 {
		a.parent().children << a.id
	} else {
		doc.children << a.id
	}
	doc.elements[a.id] = &a
	return &a
}
