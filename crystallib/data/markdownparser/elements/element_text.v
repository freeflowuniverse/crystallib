module elements


pub struct Text {
	DocBase		
pub mut:
	content string
	endlf   bool // if there is a linefeed or \n at end	
}

fn (mut self Action) process() !int {
	self.processed = true
	self.parent.elements<<self
	return 0
}

fn (self Text) markdown() string {
	return self.content
}

fn (self Text) html() string {
	return self.markdown()
}

fn text_new(parent DocElement, content string) !Text {
	return Text{
		content: content
		parent: parent
	}
}
