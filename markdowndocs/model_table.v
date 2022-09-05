module markdowndocs

pub struct Table {
pub mut:
	content string
	doc 	&Doc[str: skip]
}

fn (mut o Table) process() ? {
	return
}

fn (o Table) wiki() string {
	return o.content
}

fn (o Table) html() string {
	return o.wiki()
}

fn (o Table) str() string {
	return '**** Table\n'
}
