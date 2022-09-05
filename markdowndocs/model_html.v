module markdowndocs

pub struct Html {
pub mut:
	content string
	doc 	&Doc[str: skip]
}

fn (mut o Html) process() ? {
	return
}

fn (o Html) wiki() string {
	return o.content
}

fn (o Html) html() string {
	return o.wiki()
}

fn (o Html) str() string {
	return '**** Html\n'
}
