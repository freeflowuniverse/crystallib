module elements

@[heap]
pub struct List {
	DocBase
pub mut:
	depth  int
	indent int
}

pub fn (mut self List) process() !int {
	if self.processed {
		return 0
	}

	pre := self.content.all_before('-')
	self.depth = pre.len
	self.content = self.content.all_after_first('- ')

	self.processed = true
	return 1
}

pub fn (self List) markdown() string {
	mut h := ''
	for _ in 0 .. self.indent {
		h += '  '
	}
	return '${h}- ${self.content}\n'
}

pub fn (self List) html() string {
	panic('implement')
	// return '<h${self.depth}>${self.content}</h${self.depth}>\n\n'
}
