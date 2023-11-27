module elements

pub struct Html {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Html) process() !int {
	for mut parent in self.parents {
		parent.elements << self
	}
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Html) markdown() string {
	mut out := '<html>\n'
	out += self.content
	out += '</html>\n'
	out += self.DocBase.markdown()
	return out
}

pub fn (mut self Html) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}

@[params]
pub struct HtmlNewArgs {
	ElementNewArgs
pub mut:
	replaceme string
}

pub fn html_new(args_ HtmlNewArgs) Html {
	mut args := args_
	mut a := Html{
		content: args.content
		replaceme: args.replaceme
		type_name: 'html'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
