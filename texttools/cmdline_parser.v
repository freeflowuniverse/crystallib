module texttools

enum TextArgsStatus {
	start
	quote // quote found means value in between ''
}

// remove all '..' and "..." from a text, so everything in between the quotes
pub fn text_remove_quotes(text string) string {
	mut out := ''
	mut inquote := false
	mut char := ''
	mut char_previous := ''
	for i in 0 .. text.len {
		char = text[i..i + 1]
		if char in ['"', "'"] {
			if char_previous != '\\' {
				inquote = !inquote
				char_previous = char
				continue
			}
		}
		if !inquote {
			// unmodified add, because we are in quote
			out += char
		}
		char_previous = char
	}
	return out
}

// test if an element off the array exists in the text but ignore quotes
pub fn check_exists_outside_quotes(text string, items []string) bool {
	text2 := text_remove_quotes(text)
	for i in items {
		if i in text2 {
			return true
		}
	}
	return false
}

// convert text string to arguments
// \n supported but will be \\n and only supported within '' or ""
// \' not modified, same for \"
pub fn cmd_line_args_parser(text string) ?[]string {
	mut res := []string{}
	mut quote := ''
	mut char_previous := ''
	mut arg := ''
	mut char := ''

	if check_exists_outside_quotes(text, ['<', '>', '|']) {
		if !(' ' in text) {
			return error("cannot convert text '$text' to args because no space to split")
		}
		splitted := text.split_nth(' ', 2)
		return [splitted[0], splitted[1]]
	}
	for i in 0 .. text.len {
		char = text[i..i + 1]
		// skip spaces which are not escaped
		if char == ' ' && arg == '' {
			continue
		}

		if char in ['"', "'"] {
			if char_previous != '\\' {
				if quote == '' {
					// beginning of quote need to close off previous arg
					if arg != '' {
						res << arg.trim(' ')
						arg = ''
					}
					quote = char
					char_previous = char
					continue
				} else {
					// end of quote 
					quote = ''
					res << arg.trim(' ')
					arg = ''
					char_previous = char
					continue
				}
			}
		}

		if quote != '' {
			// unmodified add, because we are in quote
			arg += char
		} else {
			if char == ' ' && arg != '' {
				res << arg.trim(' ')
				arg = ''
			} else {
				arg += char
			}
		}
		char_previous = char
	}
	if arg != '' {
		res << arg.trim(' ')
	}
	return res
}
