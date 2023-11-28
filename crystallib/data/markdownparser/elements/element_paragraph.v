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
	self.parse()!
	self.processed = true
	return 1
}

fn (mut self Paragraph) markdown() string {
	mut out := self.DocBase.markdown()
	// out += self.content  // the children should have all the content
	return out
}

fn (mut self Paragraph) html() string {
	mut out := self.DocBase.html()  //the children should have all the content
}

@[params]
pub struct ParagraphNewArgs {
	ElementNewArgs
}

pub fn paragraph_new(args_ ParagraphNewArgs) Paragraph {
	mut args := args_
	mut a := Paragraph{
		content: args.content
		type_name: 'paragraph'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
