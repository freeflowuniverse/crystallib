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

pub fn (mut self Html) markdown() !string {
	mut out := '<html>\n'
	out += self.content
	out += '</html>\n'
	out += self.DocBase.markdown()!
	return out
}

pub fn (mut self Html) pug() !string {
	return error('cannot return pug, not implemented')
}

pub fn (mut self Html) html() !string {
	mut out := self.content
	out += self.DocBase.html()!
	return out
}
