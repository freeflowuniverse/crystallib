module markdownparser

pub struct None {
	DocBase
}

fn (mut o None) process(mut items []DocItem) !int {
	return 0	
}

fn (o None) wiki() string {
	return "none"
}

fn (o None) html() string {
	return o.wiki()
}
