module gittools

import freeflowuniverse.crystallib.pathlib


pub enum GitStatus {
	unknown
	changes
	ok
	error
}

