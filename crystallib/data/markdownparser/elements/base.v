module elements

import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.paramsparser

pub struct DocBase {
pub mut:
	id int //the unique id while loading of the element in the parser
	content string
	elements   []DocElement [skip; str: skip]
	parent  &DocElement [skip; str: skip]
	path    ?pathlib.Path 
	processed bool
	params ?paramsparser.Params
	changed bool	
}


[params]
pub struct ElementNewArgs{
pub mut:
	parent &DocElement
	content string
	add2parent bool=true //means we will add to elemnts of parent
}



pub fn (mut self DocBase) save_markdown() ! {
	mut path := self.path or {pathlib.Path{}}
	if path.path.len>0{
		path.write(self.content)!
	}
}

