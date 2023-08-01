module knowledgetree

import freeflowuniverse.crystallib.texttools

[heap]
pub struct Book {
pub mut:
	name     string
	tree  	 &Tree            [str: skip]
	state    BookState
}

pub enum BookState {
	init
	ok
	error
}

