module markdowndocs

import freeflowuniverse.crystallib.texttools

enum CommentPrefix {
	short
	multi
}

pub struct Comment {
pub mut:
	content string
	prefix  CommentPrefix
}

fn (mut o Comment) process() ? {
	return
}

fn (o Comment) wiki() string {
	return o.content
}

fn (o Comment) html() string {
	return o.wiki()
}

fn (o Comment) str() string {
	return '**** Comment\n${texttools.indent(o.content, '    ')}'
}
