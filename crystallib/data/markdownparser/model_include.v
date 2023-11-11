module markdownparser

pub struct Include {
pub mut:
	content string
}

fn (mut include Include) process(mut items []DocItem) !int {
}

fn (include Include) wiki() string {
	return '!!include ${include.content}\n\n'
}

fn (include Include) html() string {
	return include.wiki()
}
