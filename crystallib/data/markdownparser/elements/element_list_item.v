module elements

import math

@[heap]
pub struct ListItem {
	DocBase
pub mut:
	depth int
	// indent     int
	order ?int
}

pub fn (mut self ListItem) process() !int {
	if self.processed {
		return 0
	}

	self.parse()!
	self.processed = true
	return 1
}

fn (mut self ListItem) parse() ! {
	mut content := self.content
	mut depth := 0
	for i := 0; i < content.len; i++ {
		if content[i] != ` ` {
			break
		}
		depth++
	}
	self.depth = depth
	content = content[depth..]

	mut prefix := ''
	if content.starts_with('- ') {
		prefix = '- '
	} else if content.starts_with('* ') {
		prefix = '* '
	} else {
		prefix = '.'
		self.order = content.all_before('.').int()
	}

	mut p := self.paragraph_new(mut self.parent_doc_, content.all_after_first(prefix).trim_space())
	p.process()!
}

fn (self ListItem) calculate_indentation() int {
	return int(math.ceil(f64(self.depth) / 4.0))
}

pub fn (self ListItem) markdown() !string {
	return self.DocBase.markdown()!
}

pub fn (self ListItem) pug() !string {
	return error('cannot return pug, not implemented')
}

pub fn (self ListItem) html() !string {
	panic('implement')
	// return '<h${self.depth}>${self.content}</h${self.depth}>\n\n'
}
