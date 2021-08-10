module texttools

// remove all leading spaces at same level

pub fn dedent(text string) string {
	mut pre := 999
	mut pre_current := 0
	mut res := []string{}

	//
	text_lines := text.split_into_lines()

	//
	for line2 in text_lines {
		line2_trimmed := line2.trim_space()
		if line2_trimmed == '' {
			continue
		}
		// println("'$line2' $pre")
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
		// println("'$line2' ${line2.len}")
		if line2_expanded_tab_trimmed == '' {
			res << ''
		} else {
			res << line2_expanded_tab[pre..]
		}
	}
	final_result := res.join_lines()
	return final_result
}

pub enum MultiLineStatus {
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
