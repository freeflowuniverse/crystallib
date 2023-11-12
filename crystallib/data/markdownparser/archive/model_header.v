module markdownparser

pub struct Header {
pub mut:
	content string
	depth   int
}

fn (mut o Header) process(mut elements []DocElement) !int {
	return
}

fn (o Header) wiki() string {
	mut h := ''
	for _ in 0 .. o.depth {
		h += '#'
	}
	return '${h} ${o.content}\n\n'
}

fn (o Header) html() string {
	return '<h${o.depth}>${o.content}</h${o.depth}>\n'
}

// fn (o Header) str() string {
// 	return '**** Header ${o.depth}: ${o.content}\n'
// }
