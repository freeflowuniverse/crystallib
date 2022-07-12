module publisher_macros

import time
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.publisher_core

fn macro_time(mut state publisher_core.LineProcessorState, mut macro texttools.MacroObj) ? {
	mut out := []string{}

	now := time.now()
	out << 'Generated on `' + now.format_ss() + '`'

	state.lines_server << out
}
