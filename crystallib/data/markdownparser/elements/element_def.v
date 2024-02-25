module elements

@[heap]
pub struct Def {
	DocBase
pub mut:
	pagekey string
}

pub fn (mut self Def) process() !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Def) markdown() string {
	if self.pagekey.len>0{
		return "[${self.pagekey}]"
	}
	mut out := self.content
	// out += self.DocBase.markdown() // for children
	return out
}

pub fn (self Def) html() string {
	mut out := self.content
	// out += self.DocBase.html()
	return out
}

pub fn (self Def) name() string {
	return self.content.to_lower().replace("_","").trim_left("*")
}
