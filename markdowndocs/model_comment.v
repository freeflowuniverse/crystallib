module markdowndocs



pub struct Comment {
pub mut:
	lines []string
}

fn (mut o Comment) process() ! {
	return
}

fn (o Comment) wiki() string {
	mut out:=""
	if o.lines.len==1{
		return "//${o.lines[0]}\n"
	}	
	for line in o.lines{
		out+="<!-- "
		out+=line.trim_space()
		out+="\n-->\n\n"
	// }else{
	// 	if o.singleline{
	// 		out+="<!-- ${o.content.trim_space()} -->\n"
	// 	}else{
	// 		out+="<!-- ${o.content.trim_space()} -->\n\n"
	// 	}
	}
	return out
}

fn (o Comment) html() string {
	return o.wiki()
}

fn comment_new(text string) Comment{
	return Comment{content:text}
}