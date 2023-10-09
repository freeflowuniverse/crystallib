module markdowndocs

pub struct Html {
pub mut:
	content string
}

fn (mut o Html) process() ! {
	return
}

fn (o Html) wiki() string {
	return '<html>\n${o.content}\n</html>\n'
}

fn (o Html) html() string {
	return o.wiki()
}

// fn (o Html) str() string {
// 	return '**** html\n${o.content}'
// }
