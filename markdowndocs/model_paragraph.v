module markdowndocs

import freeflowuniverse.crystallib.texttools

[heap]
pub struct Paragraph {
pub mut:
	content string
	links []Link	
	changed bool	
	doc 	&Doc[str: skip]
}

fn (mut o Paragraph) process() ? {
	mut lpr := o.link_parser(o.content)?
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
	// links := '$o.links'
	// return "**** Paragraph\n${texttools.indent(o.content,"    ")}\n${texttools.indent(links,"    - ")}"
	return '**** Paragraph\n${texttools.indent(o.content, '    ')}\n'
}
