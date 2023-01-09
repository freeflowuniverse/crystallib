module markdowndocs

import freeflowuniverse.crystallib.texttools

enum CommentPrefix {
	short
	multi
}

pub struct Comment {
pub mut:
	content string
	prefix  CommentPrefix
	singleline bool
}

fn (mut o Comment) process() ! {
	return
}

fn (o Comment) wiki() string {
	mut out:=""
	if o.content.trim_space().contains("\n"){
		out+="<!-- "
		out+=o.content.trim_space()
		out+="\n-->\n\n"
	}else{
		out+="<!-- ${o.content.trim_space()} -->\n\n"
	}
	return out
}

fn (o Comment) html() string {
	return o.wiki()
}

fn (o Comment) str() string {
	return '**** Comment\n${texttools.indent(o.content, '    ')}'
}

fn comment_new() Comment{
	return Comment{}
}