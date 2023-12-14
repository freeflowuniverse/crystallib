module elements

@[heap]
pub struct Header {
	DocBase
pub mut:
	depth int
}

pub fn (mut self Header) process(mut doc Doc) !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Header) markdown() string {
	mut h := ''
	for _ in 0 .. self.depth {
		h += '#'
	}
	return '${h} ${self.content}\n'
}

pub fn (self Header) html() string {
	return '<h${self.depth}>${self.content}</h${self.depth}>\n'
}

@[params]
pub struct HeaderNewArgs {
	ElementNewArgs
pub mut:
	depth int
}
