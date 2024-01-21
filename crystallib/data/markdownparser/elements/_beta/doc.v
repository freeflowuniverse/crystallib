module elements

import freeflowuniverse.crystallib.core.smartid
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct Doc {
	DocBase
pub mut:
	replaceme string
}

pub fn (mut self Doc) process(mut doc Doc) !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

pub fn (self Doc) markdown() string {
	mut out := self.content
	out += self.DocBase.markdown()
	return out
}

pub fn (self Doc) html() string {
	mut out := self.content
	out += self.DocBase.html()
	return out
}

@[params]
pub struct DocNewArgs {
	ElementNewArgs
}
