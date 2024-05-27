module texttools

import math
import freeflowuniverse.crystallib.ui.console
// v0.4.36 becomes 4036 .
// v1.4.36 becomes 1004036

pub fn version(text_ string) int {
	text := text_.to_lower().replace('v', '')
	splitted := text.split('.').filter(it.trim_space() != '').reverse().map(it.trim_space().int())
	mut nr := 0
	mut level := 0
	// console.print_debug(splitted)
	for item in splitted {
		mut power := math.powi(1000, level)
		// console.print_debug("$item * $power")
		nr += item * int(power)
		level += 1
	}
	return nr
}
