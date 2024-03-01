module elements

@[heap]
pub struct Text {
	DocBase
// pub mut:
// 	replaceme string
}

pub fn (mut self Text) process() !int {
	self.processed = true
	return 0
}

pub fn (self Text) markdown() !string {
	return self.content
}

pub fn (self Text) pug() !string {
	return error("cannot return pug, not implemented")
}


pub fn (self Text) html() !string {
	mut out := self.content
	out += self.DocBase.html()!
	return out
}
