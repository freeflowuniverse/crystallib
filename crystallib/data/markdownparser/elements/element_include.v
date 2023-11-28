module elements

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

pub fn (self Include) markdown() string {
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
pub mut:
	replaceme string
}

pub fn include_new(args_ IncludeNewArgs) Include {
	mut args := args_
	mut a := Include{
		content: args.content
		replaceme: args.replaceme
		type_name: 'include'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
