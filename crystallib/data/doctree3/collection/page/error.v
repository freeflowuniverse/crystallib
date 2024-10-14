module page

import freeflowuniverse.crystallib.core.pathlib { Path }
import freeflowuniverse.crystallib.ui.console

pub enum PageErrorCat {
	unknown
	file_not_found
	image_not_found
	page_not_found
	def
}

pub struct PageMultiError {
	Error
pub mut:
	errs []PageError
}

pub struct PageError {
	Error
pub mut:
	path Path
	msg  string
	cat  PageErrorCat
}
