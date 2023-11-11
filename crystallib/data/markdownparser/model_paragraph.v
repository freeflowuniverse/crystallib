module markdownparser

type ParagraphItem = Comment | Link | Text

[heap]
pub struct Paragraph {
pub mut:
	content string
	items   []ParagraphItem
	changed bool
}

pub fn (mut paragraph Paragraph) process(mut items []DocItem) !int {
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
	return out + '\n\n'
}

pub fn (mut paragraph Paragraph) markdown() string {
	mut out := ''
	for mut item in paragraph.items {
		match mut item {
			Text { out += item.wiki() }
			Link { out += item.markdown() }
			Comment { out += item.wiki() }
		}
	}
	return out + '\n\n'
}

pub fn (mut paragraph Paragraph) html() string {
	mut out := ''
	for mut item in paragraph.items {
		match mut item {
			Text { out += item.html() }
			Link { out += item.html() }
			Comment { out += item.html() }
		}
	}
	return out
}
