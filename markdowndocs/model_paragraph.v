module markdowndocs

import freeflowuniverse.crystallib.texttools

pub struct Paragraph {
pub:
	content string
pub mut:
	links []Link
}

fn (mut o Paragraph) process() ? {
	mut lpr := link_parser(o.content)?
	o.links = lpr.links
	return
}

fn (o Paragraph) wiki() string {
	return o.content
}

fn (o Paragraph) html() string {
	return o.wiki()
}

fn (o Paragraph) str() string {
	links := '$o.links'
	// return "**** Paragraph\n${texttools.indent(o.content,"    ")}\n${texttools.indent(links,"    - ")}"
	return '**** Paragraph\n${texttools.indent(o.content, '    ')}\n'
}
