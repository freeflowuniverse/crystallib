module macros

import freeflowuniverse.crystallib.core.texttools

pub fn macro_pdf(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	url := macro.params.get('url')?
	state.lines_server << "<tf-pdf url=\"${url}\"></tf-pdf>"
}
