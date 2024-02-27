module elements

@[heap]
pub struct ListItem {
	DocBase
pub mut:
	depth      int
	indent     int
	order      int
	is_ordered bool
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
		self.is_ordered = true
		prefix = '.'
	}
	
	mut p := self.paragraph_new(mut self.parent_doc_, content.all_after_first(prefix).trim_string_right('\n'))
	p.process()!
}

pub fn (self ListItem) markdown()! string {
	mut h := ''
	for _ in 0 .. self.indent*4 {
		h += ' '
	}

	mut prefix := '-'
	if self.is_ordered {
		prefix = '${self.order}.'
	}

	content := self.DocBase.markdown()!
	return '${h}${prefix} ${content}'
}

pub fn (self ListItem) pug() !string {
	return error("cannot return pug, not implemented")
}


pub fn (self ListItem) html() !string {
	panic('implement')
	// return '<h${self.depth}>${self.content}</h${self.depth}>\n\n'
}
