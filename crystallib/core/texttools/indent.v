module texttools

pub fn indent(text string, prefix string) string {
	mut res := []string{}
	for line in text.split_into_lines() {
		res << prefix + line
	}
	mut t := res.join_lines()
	if !t.ends_with('\n') {
		t += '\n'
	}
	return t
}

// remove all leading spaces at same level
pub fn dedent(text string) string {
	mut pre := 999
	mut pre_current := 0
	mut res := []string{}
	text_lines := text.split_into_lines()

	for line2 in text_lines {
		if line2.trim_space() == '' {
			continue
		}
		line2_expanded_tab := line2.replace('\t', '    ')
		line2_expanded_tab_trimmed := line2_expanded_tab.trim_left(' ')
		pre_current = line2_expanded_tab.len - line2_expanded_tab_trimmed.len
		if pre > pre_current {
			pre = pre_current
		}
	}
	// now remove the prefix length
	for line2 in text_lines {
		line2_expanded_tab := line2.replace('\t', '    ') // important to deal with tabs
		line2_expanded_tab_trimmed := line2.trim_space()

		if line2_expanded_tab_trimmed == '' {
			res << ''
		} else {
			res << line2_expanded_tab[pre..]
		}
	}
	final_result := res.join_lines()
	return final_result
}
