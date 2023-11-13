module mdbook

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import log
import os


pub struct MDBookCollection {
	book &MDBook
pub mut:
	name string
	url string
	reset bool
	pull bool
	gitrepokey string
}

[params]
pub struct MDBookCollectionArgs {
pub mut:
	name string
	url string
	reset bool
	pull bool
}
