module elements

@[heap]
pub struct Comment {
	DocBase
pub mut:
	replaceme  string
	singleline bool
}

pub fn (mut self Comment) process() !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Comment) markdown() string {
	mut out := '<!--'
	out += self.content
	out += '-->'

	// out += self.DocBase.markdown()
	return out
}

pub fn (self Comment) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}
