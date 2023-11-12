module markdownparser


pub struct Comment {
pub mut:
	content string
	// prefix  CommentPrefix
	singleline bool
}

fn (mut o Comment) process(mut elements []DocElement) !int {
	return
}

fn (o Comment) wiki() string {
	if o.singleline {
		return '//${o.content}\n'
	}
	return '<!--${o.content}-->' // out
}

fn (o Comment) html() string {
	return o.wiki()
}

fn comment_new(text string) Comment {
	return Comment{
		content: text
	}
}
