module elements

@[heap]
pub struct Def {
	DocBase
pub mut:
	pagekey   string
	pagename  string
	nameshort string
}

pub fn (mut self Def) process() !int {
	if self.processed {
		return 0
	}
	if self.nameshort == '' {
		if self.content == '' {
			return error('cannot get name content should not be empty.')
		}
		self.nameshort = self.content.to_lower().replace('_', '').trim('*')
	}
	self.processed = false
	return 1
}

pub fn (mut self Def) process_link() ! {
	// self.trailing_lf = false
	self.link_new(mut self.parent_doc(), '[${self.pagename}](${self.pagekey})')
	self.process_children()!
	self.content = ''
	self.processed = true
}

pub fn (self Def) markdown() !string {
	if !self.processed {
		return self.content
	}
	
	return self.DocBase.markdown() // for children
}

pub fn (self Def) html() !string {
	if !self.processed {
		return error('cannot do markdown for ${self} as long as not processed')
	}
	return self.DocBase.html() // for children
}

pub fn (self Def) pug() !string {
	if !self.processed {
		return error('cannot do markdown for ${self} as long as not processed')
	}
	return self.DocBase.pug() // for children
}
