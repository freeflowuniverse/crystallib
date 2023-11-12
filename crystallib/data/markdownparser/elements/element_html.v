module elements

pub struct HTML {
	DocBase	
pub mut:
	replaceme string
}

fn (mut self HTML) process() !int {
	self.parent.elements<<self
	if self.processed{		
		return 0
	}
	self.processed = true
	return 1
}

fn (mut self HTML) markdown() string {
	return self.Base.markdown()
}

fn (mut self HTML) html() string {
	return self.Base.html()
}


[params]
pub HTMLNewArgs{
	ElementNewArgs
pub mut:
	replaceme string
}

fn html_new(args HTMLNewArgs) !Action {
	mut a:=html{
		content: args.content
		parent: args.parent
		replaceme string
	}
	if args.add2parent{
		args.parent.elements << a
	}
	return a
}
