module markdownparser

pub struct None {
	DocBase
}

fn (mut o None) process(mut elements []DocElement) !int {
	return 0	
}

fn (o None) markdown() string {
	return "none"
}

fn (o None) html() string {
	return o.markdown()
}
