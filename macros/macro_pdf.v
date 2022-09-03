module publisher

import freeflowuniverse.crystallib.texttools

pub fn macro_pdf(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	url := macro.params.get('url')?
	state.lines_server << "<tf-pdf url=\"$url\"></tf-pdf>"
}
