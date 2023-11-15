module elements

pub struct Table {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Table) process() !int {
	for mut parent in self.parents {
		parent.elements << self
	}
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Table) markdown() string {
	mut out := self.content
	out += self.DocBase.markdown()
	return out
}

pub fn (mut self Table) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}

[params]
pub struct TableNewArgs {
	ElementNewArgs
pub mut:
	replaceme string
}

pub fn table_new(args_ TableNewArgs) Table {
	mut args := args_
	mut a := Table{
		content: args.content
		replaceme: args.replaceme
		type_name: 'table'
		parents: args.parents
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
