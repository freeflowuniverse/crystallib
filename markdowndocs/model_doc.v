module markdowndocs

import pathlib

pub struct Doc {
pub mut:
	items   []DocItem
	path    pathlib.Path
	content string
}

type DocItem = Action
	| Actions
	| CodeBlock
	| Comment
	| DocStart
	| Header
	| Html
	| Paragraph
	| Table
	| Text

// fn (mut o DocItem) str() string{
// 	return "$o"
// }

pub struct DocStart {
pub mut:
	content string
}

fn (mut o DocStart) process() ? {
}

fn (o DocStart) wiki() string {
	return o.content
}

fn (o DocStart) html() string {
	return o.wiki()
}

fn (o DocStart) str() string {
	return '**** DOCSTART\n'
}

fn (mut doc Doc) process() ? {
	for mut item in doc.items {
		match mut item {
			DocStart { item.process()? }
			Text { item.process()? }
			Table { item.process()? }
			Action { item.process()? }
			Actions { item.process()? }
			Header { item.process()? }
			Paragraph { item.process()? }
			Html { item.process()? }
			Comment { item.process()? }
			CodeBlock { item.process()? }
		}
	}
}

fn (doc Doc) str() string {
	mut out := ''
	for item in doc.items {
		match item {
			DocStart { out += item.str() }
			Text { out += item.str() }
			Table { out += item.str() }
			Action { out += item.str() }
			Actions { out += item.str() }
			Header { out += item.str() }
			Paragraph { out += item.str() }
			Html { out += item.str() }
			Comment { out += item.str() }
			CodeBlock { out += item.str() }
		}
	}
	return out
}

pub fn (doc Doc) html() string {
	mut out := ''
	for item in doc.items {
		match item {			
			DocStart { out += item.str() }
			Text { out += item.str() }
			Table { out += item.str() }
			Action { out += item.str() }
			Actions { out += item.str() }
			Header { out += '<h$item.depth>${item.content}</h$item.depth>\n' }
			Paragraph { out += '<p>${item.content}</p>\n' }
			Html { out += item.str() }
			Comment { out += item.str() }
			CodeBlock { out += item.str() }
		}
	}
	return out
}

pub fn (mut doc Doc) save() ? {
	doc.path.write(doc.content)?
}
