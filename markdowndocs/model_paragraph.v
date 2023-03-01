module markdowndocs

type ParagraphItem = Text | Link | Comment

[heap]
pub struct Paragraph {
pub mut:
	content string
	items   []ParagraphItem
	changed bool
}

fn (mut paragraph Paragraph) process() ! {
	if paragraph.items.len == 0 {
		paragraph.parse()!
	}	
}


pub fn (mut paragraph Paragraph) wiki() string {
	mut out := ''
	for mut item in paragraph.items {
		match mut item {
			Text { out += item.wiki() }
			Link { out += item.wiki() }
			Comment { out += item.wiki() }
		}
	}
	return out + "\n\n"
}

pub fn (mut paragraph Paragraph) html() string {
	mut out := ''
	for mut item in paragraph.items {
		match mut item{
			Text { out += item.html() }
			Link { out += item.html() }
			Comment { out += item.html() }
		}
	}
	return out
}

// fn (mut paragraph Paragraph) str() string {
// 	mut out := ''
// 	for mut item in paragraph.items {
// 		match mut item{
// 			Text {out += item.str()}
// 			Link {out += item.str()}
// 			Comment {out += item.str()}
// 		}
// 	}
// 	return out
// }




// fn (mut paragraph Paragraph) last_item_name() string {
// 	return parser.doc.items.last().type_name().all_after_last('.').to_lower()
// }

// // if state is this name will return true
// fn (mut paragraph Paragraph) last_item_name_check(tocheck string) bool {
// 	if paragraph.last_item_name() == tocheck.to_lower().trim_space() {
// 		return true
// 	}
// 	return false
// }