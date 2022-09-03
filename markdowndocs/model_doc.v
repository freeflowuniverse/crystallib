module markdowndocs

pub struct Doc{
pub mut:
	items []DocItem
}


type DocItem = DocStart | Text | Table  | Action | Actions  | Header | Paragraph | Html | Comment | CodeBlock


// fn (mut o DocItem) str() string{
// 	return "$o"
// }




pub struct DocStart{
pub mut:
	content string
}

fn (mut o DocStart) process()?{
	
}

fn ( o DocStart) wiki() string{
	return o.content
	
}

fn ( o DocStart) html() string{
	return o.wiki()
}

fn ( o DocStart) str() string{
	return "**** DOCSTART\n"
}


fn (mut doc Doc) process()?{
	for mut item in doc.items{
		match mut item {
			DocStart {item.process()?}
			Text {item.process()?}
			Table {item.process()?}
			Action {item.process()?}
			Actions {item.process()?}
			Header {item.process()?}
			Paragraph {item.process()?}
			Html {item.process()?}
			Comment {item.process()?}
			CodeBlock {item.process()?}
		}
	}
}




fn ( doc Doc) str()string{
	mut out := ""
	for item in doc.items{
		match item {
			DocStart {out+=item.str()}
			Text {out+=item.str()}
			Table {out+=item.str()}
			Action {out+=item.str()}
			Actions {out+=item.str()}
			Header {out+=item.str()}
			Paragraph {out+=item.str()}
			Html {out+=item.str()}
			Comment {out+=item.str()}
			CodeBlock {out+=item.str()}
		}
	}
	return out
	
}



