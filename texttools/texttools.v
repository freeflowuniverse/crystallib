module texttools

// remove all leading spaces at same level
pub fn dedent(text string) string {
	mut pre := 999
	mut pre_current := 0
	mut line2 := ''
	mut res := []string{}
	for line in text.split_into_lines() {
		line2 = line
		if line2.trim_space() == '' {
			continue
		}
		// println("'$line2' $pre")
		line2 = line2.replace('\t', '    ')
		pre_current = line2.len - line2.trim_left(' ').len
		if pre > pre_current {
			pre = pre_current
		}
	}
	// now remove the prefix length
	for line in text.split_into_lines() {
		line2 = line
		line2 = line2.replace('\t', '    ') // important to deal with tabs
		// println("'$line2' ${line2.len}")
		if line2.trim_space() == '' {
			res << ''
		} else {
			res << line2[pre..]
		}
	}
	return res.join_lines()
}

enum MultiLineStatus {
	start
	multiline
}

// converst a multiline to a single line, keeping all relevant information
// empty lines removed (unless if in parameter)
// commented lines removed as well (starts with // and #)
// multiline to 'line1\\nline2\\n'
// dedent also done before putting in '...'
// tabs also replaced to 4x space
pub fn multiline_to_single(text string) ?string {
	mut multiline_first := ''
	mut multiline := ''
	mut line2 := ''
	mut res := []string{}
	mut state := MultiLineStatus.start
	for line in dedent(text).split_into_lines() {
		line2 = line
		line2 = line2.replace('\t', '    ')
		// println("'$line2' $state")
		if state == MultiLineStatus.multiline {
			// println("LINE2:'$line2'")
			if line2.starts_with(' ') {
				multiline += '$line2\n'
				continue
			} else if line2.trim_space() == '' {
				multiline += '\n'
				continue
			} else {
				// means we are out of multiline
				state = MultiLineStatus.start
				res << multiline_end(multiline_first, multiline)
				multiline_first = ''
				multiline = ''
				state = MultiLineStatus.start
			}
		}
		if state == MultiLineStatus.start {
			if line2.trim_space() == '' {
				continue
			}
			if line2.trim_space().starts_with('#') {
				continue
			}
			if line2.trim_space().starts_with('//') {
				continue
			}
			if line2.trim_space().ends_with(":'") || line2.trim_space().ends_with(": '") {
				return error("line cannot end with ': '' or ':'' in \n%text")
			}
			if line2.trim_space().ends_with(':') {
				// means is multiline
				state = MultiLineStatus.multiline
				multiline_first = line2
				continue
			} else {
				res << line2
			}
		}
	}
	// last one
	if state == MultiLineStatus.multiline {
		res << multiline_end(multiline_first, multiline)
	}
	return res.join_lines()
}

fn multiline_end(multiline_first string, multiline string) string {
	mut multiline2 := multiline
	// println("MULTILINE:\n$multiline\n----")
	multiline2 = dedent(multiline2)
	multiline2 = multiline2.replace('\n', '\\n')
	multiline2 = multiline2.replace("'", '"')
	multiline2 = "$multiline_first'$multiline2'"
	return multiline2
}

struct TextParams {
pub mut:
	params []TextParam
}

struct TextParam {
pub:
	key   string
	value string
}

enum TextParamStatus {
	start
	name // found name of the var
	value_wait // wait for value to start (can be quote or end of spaces and first meaningful char)
	value // value started, so was no quote
	quote // quote found means value in between ''
}

// convert text with e.g. color:red or color:'red' to arguments
// multiline is supported
pub fn text_to_params(text string) ?TextParams {
	mut text2 := ''
	text2 = multiline_to_single(text) ?
	text2 = text2.replace('\\n', '<<BR>>')
	text2 = text2.replace('\n', ' ')

	validchars := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'

	mut char := ''
	mut state := TextParamStatus.start
	mut result := TextParams{}
	mut key := ''
	mut value := ''

	for i in 0 .. text2.len {
		char = text2[i..i + 1]
		// println(" - $char ${state}")
		// check for comments end
		if state == TextParamStatus.start {
			if char == ' ' {
				continue
			}
			state = TextParamStatus.name
		}
		if state == TextParamStatus.name {
			if char == ' ' {
				continue
			}
			// waiting for :
			if char == ':' {
				state = TextParamStatus.value_wait
				continue
			} else if !validchars.contains(char) {
				println('\n\nERROR:')
				return error("parameters can only be A-Za-z0-9 and _, here found: '$key$char' in\n$text2")
			} else {
				key += char
				continue
			}
		}
		if state == TextParamStatus.value_wait {
			if char == "'" {
				state = TextParamStatus.quote
				continue
			}
			// means the value started, we can go to next state
			if char != ' ' {
				state = TextParamStatus.value
			}
		}
		if state == TextParamStatus.value {
			if char == ' ' {
				state = TextParamStatus.start
				result.add(key, value)
				key = ''
				value = ''
			} else {
				value += char
			}
			continue
		}
		if state == TextParamStatus.quote {
			if char == "'" {
				state = TextParamStatus.start
				result.add(key, value)
				key = ''
				value = ''
			} else {
				value += char
			}
			continue
		}
	}

	// last value
	if state == TextParamStatus.value || state == TextParamStatus.quote {
		result.add(key, value)
	}

	return result
}

fn (mut result TextParams) add(key string, value string) {
	mut key2 := ''
	mut value2 := ''

	key2 = key.to_lower().trim_space()

	value2 = value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')

	result.params << TextParam{
		key: key2
		value: value2
	}
}

enum TextArgsStatus {
	start
	quote // quote found means value in between ''
}

// remove all '..' and "..." from a text
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
pub fn text_to_args(text string) ?[]string {
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

// //check the char is in a...Z0..9
// fn is_var_char(char string) bool{
//     tocheck:="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
//     if char in tocheck{
//         return true
//     }
//     return false
// }

// //find variables which is $[a...zA...Z0...9]
// pub fn template_find_args(text string)[]string{
//     mut var := ""
//     mut res := []string{}
//     mut invar := false
//     mut quoted := false
//     for i in text {
//         if i =="$"{
//             invar = true
//             var = ""
//             continue
//         }
//         if invar{
//             if i =="{"{
//                 quoted=true
//                 continue
//             }
//             if quoted &&  i =="}" {
//                 quoted = false
//                 res << var
//                 var = ""
//                 invar = false
//                 continue
//             }
//             if is_var_char(i) || quoted {
//                 var += i
//             }else{
//                 res << var
//                 var = ""
//                 invar = false
//             }
//         }
//     }
//     return res
// }

// //find variables which is $[a...zA...Z0...9]
// pub fn template_replace_args(text string, args map[string]string )?string{
//     mut args2 := map[string]string{}
//     mut text2 := text
//     for key in args.key_values{
//         args2[key.to_upper()]=args[key]
//     }
//     for arg in template_find_args(text){        
//         if arg.to_upper() in args2{
//             text2 = text2.replace("\$${arg}",args2[arg.to_upper()])
//         }else{
//             return error("Cannot find $arg in\n$text2")
//         }
//     }
//     return text2
// }
