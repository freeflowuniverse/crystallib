module markdownparser

import freeflowuniverse.crystallib.ui.console

pub fn markdown_min_header(text string, minlevel int) string {
	mut nrhash := 100
	mut out := []string{}

	for line in text.split('\n') {
		if line.starts_with('#') {
			splitted := line.split_nth(' ', 2)
			nrhash2 := splitted[0].count('#')
			if nrhash2 < nrhash {
				nrhash = nrhash2
			}
		}
	}

	// nrhash has now the min header level found
	// console.print_debug('minlevel: $minlevel nrhash:$nrhash')

	mut addhashstring := ''
	if minlevel > nrhash {
		for _ in 0 .. (minlevel - nrhash) {
			addhashstring += '#'
		}
		for mut line2 in text.split('\n') {
			if line2.starts_with('#') {
				line2 = addhashstring + '${line2}'
			}
			out << line2
		}
	}

	return out.join('\n')
}
