module markdowndocs

pub struct Header {
pub mut:
	content string
	depth   int
	doc 	&Doc[str: skip]
}

fn (mut o Header) process() ? {
	return
}

fn (o Header) wiki() string {
	return o.content
}

fn (o Header) html() string {
	return o.wiki()
}

fn (o Header) str() string {
	return '**** Header $o.depth: $o.content\n'
}
