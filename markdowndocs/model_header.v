module markdowndocs

pub struct Header {
pub mut:
	content string
	depth   int
}

fn (mut o Header) process() ! {
	return
}

fn (o Header) wiki() string {
	mut h := ''
	for _ in 0 .. o.depth {
		h += '#'
	}
<<<<<<< HEAD
	h += ' '
=======
>>>>>>> 667df183094470ef5dbeba569d84a1ac2b27784e
	return '${h} ${o.content}\n\n'
}

fn (o Header) html() string {
	return o.wiki()
}

// fn (o Header) str() string {
// 	return '**** Header ${o.depth}: ${o.content}\n'
// }
