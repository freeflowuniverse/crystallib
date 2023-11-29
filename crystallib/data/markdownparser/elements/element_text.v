module elements

@[heap]
pub struct Text {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Text) process(mut doc Doc) !int {
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

@[params]
pub struct TextNewArgs {
	ElementNewArgs
}
