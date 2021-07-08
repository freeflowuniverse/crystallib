module publisher_core

import time
import despiegk.crystallib.texttools

fn macro_time(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut out := []string{}

	now := time.now()
	out << 'Generated on `' + now.format_ss() + '`'

	state.lines_server << out
}
