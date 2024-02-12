module elements

@[heap]
pub struct Text {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Text) process() !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Text) markdown() string {
	mut out := self.content
	out += self.DocBase.markdown() //for children
	return out
}

pub fn (self Text) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}
