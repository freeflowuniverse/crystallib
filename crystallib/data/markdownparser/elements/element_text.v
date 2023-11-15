module elements

pub struct Text {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Text) process() !int {
	for mut parent in self.parents {
		parent.elements << self
	}
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (mut self Text) markdown() string {
	mut out := self.content
	out += self.DocBase.markdown()
	return out
}

pub fn (mut self Text) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}

[params]
pub struct TextNewArgs {
	ElementNewArgs
pub mut:
	replaceme string
}

pub fn text_new(args_ TextNewArgs) Text {
	mut args := args_
	mut a := Text{
		content: args.content
		replaceme: args.replaceme
		type_name: 'text'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
