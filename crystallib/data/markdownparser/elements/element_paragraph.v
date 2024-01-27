module elements

@[heap]
pub struct Paragraph {
	DocBase // pub mut:
	// elements   []ParagraphElement
}

fn (mut self Paragraph) process() !int {
	if self.processed {
		return 0
	}

	self.paragraph_parse()!
	self.process_base()!
	self.process_elements()!
	self.processed = true
	return 1
}

fn (self Paragraph) markdown() string {
	mut out := self.DocBase.markdown()
	// out += self.content  // the children should have all the content
	return out + '\n'
}

fn (self Paragraph) html() string {
	mut out := self.DocBase.html() // the children should have all the content
	return out
}
