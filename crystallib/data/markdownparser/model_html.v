module markdownparser

pub struct Html {
pub mut:
	content string
}

fn (mut o Html) process(mut items []DocItem) !int {
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
