module publisher_macros

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher_core

pub fn macro_pdf(mut state publisher_core.LineProcessorState, mut macro texttools.MacroObj) ? {
	url := macro.params.get('url')?
	state.lines_server << "<tf-pdf url=\"$url\"></tf-pdf>"
}
