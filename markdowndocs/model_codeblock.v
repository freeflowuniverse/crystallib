module markdowndocs

pub struct CodeBlock{
pub mut:
	content string
	category string
}

fn (mut o CodeBlock) process()?{
	return
}

fn ( o CodeBlock) wiki() string{
	return o.content
	
}

fn ( o CodeBlock) html() string{
	return o.wiki()
}

fn ( o CodeBlock) str() string{
	return "**** CodeBlock\n"
}


