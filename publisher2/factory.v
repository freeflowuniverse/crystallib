module publisher2

import os
import freeflowuniverse.crystallib.pathlib {Path}

// install mdbook will return true if it was already installed
pub fn get() ?Publisher {
	mut publisher := Publisher{
	}

	return publisher
}