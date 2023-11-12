module elements


// type ParagraphElement = Comment | Link | Text

[heap]
pub struct Paragraph {
	DocBase	
// pub mut:
	// elements   []ParagraphElement
}

fn (mut self Paragraph) process() !int {
	for mut parent in self.parents{
		parent.elements<<self
	}	
	if self.processed{		
		return 0
	}
	self.processed = true
	return 1
}

fn (mut self Paragraph) markdown() string {
	mut out:=self.DocBase.markdown()
	out+=self.content
	return out
}

fn (mut self Paragraph) html() string {
	return self.markdown()
}

// pub fn (mut paragraph Paragraph) wiki() string {
// 	mut out := ''
// 	for mut element in paragraph.elements {
// 		match mut element {
// 			Text { out += element.wiki() }
// 			Link { out += element.wiki() }
// 			Comment { out += element.wiki() }
// 		}
// 	}
// 	return out + '\n\n'
// }

// pub fn (mut paragraph Paragraph) markdown() string {
// 	mut out := ''
// 	for mut element in paragraph.elements {
// 		match mut element {
// 			Text { out += element.wiki() }
// 			Link { out += element.markdown() }
// 			Comment { out += element.wiki() }
// 		}
// 	}
// 	return out + '\n\n'
// }

// pub fn (mut paragraph Paragraph) html() string {
// 	mut out := ''
// 	for mut element in paragraph.elements {
// 		match mut element {
// 			Text { out += element.html() }
// 			Link { out += element.html() }
// 			Comment { out += element.html() }
// 		}
// 	}
// 	return out
// }
