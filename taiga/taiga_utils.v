module taiga

import texttools
import time { Time, now, parse_iso8601 }
import math { pow10 }

pub fn parse_time(date_time string) Time {
	if date_time == 'null' {
		return Time{}
	}
	return parse_iso8601(date_time) or { Time{} }
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

pub fn get_category(t TaigaElement) Category {
	time_now := now()
	if t.is_blocked {
		return .blocked
	} else if t.due_date != Time{} {
		difference := (t.due_date - time_now) / (pow10(9) * 3600 * 24)
		if difference < -60 {
			return .old
		} else if difference < 0 {
			return .overdue
		} else if difference <= 1 {
			return .today
		} else if difference <= 2 {
			return .in_two_days
		} else if difference <= 7 {
			return .in_week
		} else if difference <= 30 {
			return .in_month
		}
	}
	return .other
}

pub fn generate_file_name(s string) string {
	mut file_name := texttools.name_clean(s)
	file_name = texttools.ascii_clean(file_name)
	file_name = file_name.replace(' ', '_').to_lower()
	return file_name
}
