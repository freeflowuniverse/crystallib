module taiga

import time

pub fn parse_time(date_time string) time.Time {
	if date_time == 'null' {
		return time.Time{}
	}
	return time.parse_iso8601(date_time) or { time.Time{} }
}

// Return md file with correct empty lines
pub fn fix_empty_lines(md string) string {
	mut export_md := ''
	for i, line in md.split_into_lines() {
		if line.starts_with('#') || line.starts_with('>') {
			// Every header needs a new line before it and an empty file after it.
			if i == 0 {
				export_md += line + '\n\n'
			} else {
				export_md += '\n' + line + '\n\n'
			}
		} else if line == '' {
			// Ignore empty lines.
			continue
		} else {
			// Anything else will add the line as it is
			export_md += line + '\n'
		}
	}
	return export_md
}
