module elements

pub struct Header {
	DocBase
pub mut:
	depth     int
}

pub fn (mut self Header) process() !int {
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

pub fn (mut self Header) html() string {
	return '<h${self.depth}>${self.content}</h${self.depth}>\n'
}

@[params]
pub struct HeaderNewArgs {
	ElementNewArgs
pub mut:
	depth int
}

pub fn header_new(args_ HeaderNewArgs) Header {
	mut args := args_
	mut a := Header{
		content: args.content
		depth: args.depth
		type_name: 'header'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
