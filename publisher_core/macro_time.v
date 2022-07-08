module publisher_core

import time
import freeflowuniverse.crystallib.texttools

fn macro_time(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut out := []string{}

	now := time.now()
	out << 'Generated on `' + now.format_ss() + '`'

	state.lines_server << out
}
