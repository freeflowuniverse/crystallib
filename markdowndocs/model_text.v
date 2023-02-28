module markdowndocs

pub struct Text {
pub mut:
	content string
	endlf bool //if there is a linefeed or \n at end	
}

fn (mut o Text) process() ! {
	return
}

fn (o Text) wiki() string {
	return o.content
}

fn (o Text) html() string {
	return o.wiki()
}

// fn (o Text) str() string {
// 	return '**** Text\n'
// }


fn text_new(content string) !Text {
	return Text{content:content}
}
