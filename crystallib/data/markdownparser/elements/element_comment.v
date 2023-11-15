module elements

pub struct Comment {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Comment) process() !int {
	for mut parent in self.parents {
		parent.elements << self
	}
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Comment) markdown() string {
	mut out := self.content
	out += self.DocBase.markdown()
	return out
}

pub fn (mut self Comment) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}

[params]
pub struct CommentNewArgs {
	ElementNewArgs
pub mut:
	replaceme string
}

pub fn comment_new(args_ CommentNewArgs) Comment {
	mut args := args_
	mut a := Comment{
		content: args.content
		replaceme: args.replaceme
		type_name: 'comment'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
