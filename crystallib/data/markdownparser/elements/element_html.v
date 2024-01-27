module elements

@[heap]
pub struct Html {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Html) process() !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Html) markdown() string {
	mut out := '<html>\n'
	out += self.content
	out += '</html>\n'
	out += self.DocBase.markdown()
	return out
}

pub fn (self Html) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}
