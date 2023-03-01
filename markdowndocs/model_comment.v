module markdowndocs


// enum CommentPrefix {
// 	short
// 	multi
// }

pub struct Comment {
pub mut:
	content string
	// prefix  CommentPrefix
	singleline bool
}

fn (mut o Comment) process() ! {
	return
}

fn (o Comment) wiki() string {
	mut out := ""
	if o.singleline {
		return "//${o.content}\n"
	}	
	if o.content.trim_space().contains("\n") {
		out += "<!-- "
		out += o.content.trim_space()
		out += "\n-->\n\n"
	} else {
		if o.singleline {
			out += "<!-- ${o.content.trim_space()} -->\n"
		} else {
			out += "<!-- ${o.content.trim_space()} -->\n\n"
		}
	}
	return out
}

fn (o Comment) html() string {
	return o.wiki()
}

fn comment_new(text string) Comment {
	return Comment{ content:text }
}