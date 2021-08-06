module planner

import time
import despiegk.crystallib.texttools

fn line_parser_params(line string) ?(bool, texttools.Params) {
	if line.starts_with('?') {
		line2 := line[1..]
		p := texttools.text_to_params(line2) ?
		return true, p
	}
	mut p := texttools.new_params()
	return false, p
}

