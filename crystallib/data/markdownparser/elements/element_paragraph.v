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
	self.process_children()!
	self.processed = true
	self.content = ''
	if self.children.len > 0 {
		mut l := self.children.last()
		l.trailing_lf = true
	}

	return 1
}

fn (self Paragraph) markdown() !string {
	mut out := self.DocBase.markdown()!
	// out += self.content  // the children should have all the content
	return out
}

pub fn (self Paragraph) pug() !string {
	return error("cannot return pug, not implemented")
}

fn (self Paragraph) html() !string {
	mut out := self.DocBase.html()! // the children should have all the content
	return out
}
