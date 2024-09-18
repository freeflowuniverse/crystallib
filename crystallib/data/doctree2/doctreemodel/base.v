module doctreemodel

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.markdownparser.elements { Doc }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.ui.console

pub enum Status {
	unknown
	ok
	error
}

@[heap]
pub struct Base {
mut:
	collection &Collection @[str: skip]
	doc_            ?&Doc    @[str: skip]
	pathobj_    ?pathlib.Path
pub mut:
	pointer	Pointer
	alias   string // a proper name for e.g. def
	state   Status
	//categories      []string
}


pub fn (mut self Base) pathobj() !pathlib.Path {
	mut pathobj:= page.path or {
		mut p:=pathlib.file_get(self.path())!
		p
	}
	self.pathobj_ = pathobj
	return self.pathobj_
}

pub fn (self Base) path() string {
	if self.ext.len>0{
		return '${self.collection.path}/${self.pointer.name}.md'
	}else{
		return '${self.collection.path}/img/${self.pointer.name}.${self.pointer.ext}'
	}
}


pub fn (self Base) key() string {
	if self.ext.len>0{
		return '${self.collection.name}:${self.pointer.name}'
	}else{
		return '${self.collection.name}:${self.name}.${self.pointer.ext}'
	}
	
}
