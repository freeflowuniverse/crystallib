module markdowndocs

pub struct CodeBlock {
pub mut:
	content  string
	category string
}

fn (mut o CodeBlock) process() ! {
	return
}

fn (o CodeBlock) wiki() string {
	mut out := ''
	out += '```${o.category}\n'
	out += o.content.trim_space()
	out += '\n```\n\n'
	return out
}

fn (o CodeBlock) html() string {
	return o.wiki()
}
