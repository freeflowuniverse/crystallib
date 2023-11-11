module texttools

pub enum MultiLineStatus {
	start
	multiline
	comment
}

// converst a multiline to a single line, keeping all relevant information
// empty lines removed (unless if in parameter)
// commented lines removed as well (starts with // and #)
// multiline to 'line1\\nline2\\n'
// dedent also done before putting in '...'
// tabs also replaced to 4x space
pub fn multiline_to_single(text string) !string {
	mut multiline_first := ''
	mut multiline := ''
	// mut comment_first:=""
	mut comment := []string{}
	mut line2 := ''
	mut res := []string{}
	mut state := MultiLineStatus.start
	for line in text.split_into_lines() {
		line2 = line
		line2 = line2.replace('\t', '    ')
		mut line2_trimmed := line2.trim_space()
		// println(" - ${state:-15} $line2_trimmed")	
		if state == .multiline {
			// println("MULTI:'$line2'")
			if multiline_end_check(line2_trimmed) {
				// means we are out of multiline
				res << multiline_end(multiline_first, multiline)
				multiline_first = ''
				multiline = ''
				state = .start
			} else {
				multiline += '${line2}\n'
			}
			continue
		}
		if state == .comment {
			// println("COMMENTt:'$line2'")
			if comment_end_check(line2_trimmed) {
				// means we are out of multiline
				res << comment_end(comment)
				comment = []string{}
				state = .start
			} else {
				comment << line2_trimmed
				continue
			}
		}
		if state == .start {
			if line2_trimmed == '' {
				continue
			}
			// deal with comments
			mut commentpart := ''
			line2_trimmed, commentpart = comment_start_check(mut res, line2_trimmed)
			println(" - comment_start_check:  line2_trimmed:'${line2_trimmed}' commentpart:'${commentpart}'")
			if commentpart.len > 0 {
				state = .comment
				comment = []string{}
				comment << commentpart
				continue
			}
			if multiline_start_check(line2_trimmed) {
				// means is multiline
				state = .multiline
				multiline_first = line2_trimmed
				continue
			}
			res << line2_trimmed.trim('\n ')
		}
	}
	// last one
	if state == .multiline {
		res << multiline_end(multiline_first, multiline)
	}
	if state == .comment {
		res << comment_end(comment)
	}
	return res.join(' ')
}

fn multiline_end(multiline_first string, multiline string) string {
	mut multiline2 := multiline
	// println("MULTILINE:\n$multiline\n----")
	multiline2 = dedent(multiline2)
	multiline2 = multiline2.replace('\n', '\\\\n')
	multiline2 = multiline2.replace("'", '"')

	firstline_content := multiline_first.all_after_first(':').trim_left('" \'')
	name := multiline_first.all_before(':').trim_space()

	// println( "name:${name:-20} firstline_content:${firstline_content}")

	if firstline_content.trim_space() != '' {
		multiline2 = "${name}:'${multiline_first}\\n${multiline2}'"
	} else {
		multiline2 = "${name}:'${multiline2}'"
	}
	return multiline2
}

// check that there is multiline start
fn multiline_start_check(text_ string) bool {
	if text_ == '' {
		return false
	}
	text := text_.replace(': ', ':').replace(': ', ':').replace(': ', ':')
	for tocheck in [":'", ':"', ':"""', ":'''"] {
		if text.ends_with(tocheck) {
			return true
		}
	}
	return false
}

fn multiline_end_check(text string) bool {
	if text == "'" || text == '"' || text == '"""' || text == "'''" {
		return true
	}
	return false
}

// return all before comment and if comment
// return trimmedtext,commentpart
fn comment_start_check(mut res []string, text_ string) (string, string) {
	mut text := text_
	if text.starts_with('<!--') {
		text = text.replace('<!--', '').trim_space()
		return '', text
	}
	if !(text.contains('//')) {
		return text, ''
	}
	mightbecomment := text.all_after_last('//')
	if !(mightbecomment.contains("'")) {
		// means we found a comment at end of line, and is not part of string statement (value)
		text = text.all_before_last('//').trim_space()
		if text.len > 0 {
			res << '//${mightbecomment}-/'
			return text, ''
		} else {
			return '', mightbecomment
		}
	}
	return text, ''
}

fn comment_end_check(text string) bool {
	if text.ends_with('-->') {
		return true
	}
	if !text.starts_with('//') {
		return true
	}
	return false
}

fn comment_end(comment []string) string {
	// println(comment)
	mut out := []string{}
	for line in comment {
		out << line.trim(' <->/\n')
	}
	mut outstr := out.join('\\\\n')
	return '//${outstr}-/'
}
