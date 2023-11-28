module elements

[heap]
pub struct Include {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Include) process() !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (mut self Include) markdown() string {
	mut out := self.content
	out += self.DocBase.markdown()
	return out
}

pub fn (mut self Include) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}

@[params]
pub struct IncludeNewArgs {
	ElementNewArgs
}

