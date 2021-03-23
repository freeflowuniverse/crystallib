module texttools

// import regex

pub struct TokenizerResult {
pub mut:
	items []TokenizerItem
}

[unsafe]
fn (mut tr TokenizerResult) free() {
	for mut item in tr.items {
		unsafe { item.free() }
	}
	unsafe { tr.items.free() }
}

pub struct TokenizerItem {
pub mut:
	toreplace string
	// is the most fixed string
	matchstring string
}

[unsafe]
fn (mut ti TokenizerItem) free() {
	unsafe { ti.toreplace.free() }
	unsafe { ti.matchstring.free() }
}

[manualfree]
pub fn text_token_replace(text string, tofind string, replacewith string) ?string {
	mut tr := tokenize(text)
	defer {
		unsafe { tr.free() }
	}
	text2 := tr.replace(text, tofind, replacewith) ?
	return text2
}

// the map has as key the normalized string (fix_name_no_underscore), the value is what to replace with
[manualfree]
pub fn replace_items(text string, replacer map[string]string) ?string {
	mut skipline := false
	mut res := []string{}
	text_lines := text.split('\n')
	defer {
		unsafe { text_lines.free() }
	}
	for line_ in text_lines {
		mut line := line_
		if line.trim(' ').starts_with('!') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('/') {
			res << line
			continue
		}
		if line.trim(' ').starts_with('#') {
			res << line
			continue
		}
		if line.contains("'''") || line.contains('```') || line.contains('"""') {
			skipline = !skipline
		}
		if skipline {
			res << line
			continue
		}

		// TODO: is very brute force can be done much better
		mut tr := tokenize(line)
		// println(" ==== $line")
		// println(tr.items)
		for key, replacewith in replacer {
			// println(" == $defname")
			line = tr.replace(line, key, replacewith) ?
			line = tr.replace(line, key + 's', replacewith + 's') ?
		}
		unsafe { tr.free() }
		res << line
	}
	final_res := res.join('\n')
	unsafe { res.free() }
	return final_res
}

[manualfree]
pub fn (mut tr TokenizerResult) replace(text string, tofind string, replacewith string) ?string {
	tofind2 := name_fix_no_underscore(tofind)
	defer {
		unsafe { tofind2.free() }
	}
	mut text2 := text
	for item in tr.items {
		if item.matchstring == tofind2 {
			// text2 = text2.replace(item.toreplace, replacewith)
			new_text := text2.replace(item.toreplace, replacewith)
			unsafe { text2.free() }
			text2 = new_text
		}
		// } else {
		// 	println(' ... $item.matchstring !=  $tofind2')
		// }
	}
	return text2
}

[manualfree]
pub fn name_fix_no_underscore(name string) string {
	item := name_fix(name)
	defer {
		unsafe { item.free() }
	}
	newitem := item.replace('_', '')
	return newitem
}

const name_fix_replaces = [
	' ',
	'_',
	'-',
	'_',
	'__',
	'_',
	'__',
	'_', /* needs to be 2x because can be 3 to 2 to 1 */
	'::',
	'_',
	';',
	'_',
	':',
	'_',
	'.',
	'_',
]

[manualfree]
pub fn name_fix(name string) string {
	item := name.to_lower()
	item_replaced := item.replace_each(texttools.name_fix_replaces)
	newitem := item_replaced.trim(' ._')
	unsafe { item_replaced.free() }
	unsafe { item.free() }
	return newitem
}

[manualfree]
fn word_skip(text string) bool {
	lower_text := text.to_lower()
	defer {
		unsafe { lower_text.free() }
	}
	if lower_text in ['the', 'some', 'and', 'plus', 'will', 'do', 'are', 'these'] {
		return true
	}
	return false
}

[manualfree]
pub fn tokenize(text_ string) TokenizerResult {
	text := dedent(text_)
	// println(text)
	mut skip := false
	mut skipline := false
	mut prev := ''
	defer {
		unsafe { prev.free() }
	}
	mut word := ''
	defer {
		unsafe { word.free() }
	}
	mut islink := false
	mut tr := TokenizerResult{}
	mut done := []string{}
	defer {
		unsafe { done.free() }
	}
	lines := text.split('\n')
	defer {
		unsafe { lines.free() }
	}
	unsafe { text.free() } // not used anymore, free early to reduce memory usage
	//	
	for original_line in lines {
		line := original_line.trim(' ')

		if line.starts_with('!') {
			unsafe { line.free() }
			continue
		}

		if line.starts_with('http') {
			unsafe { line.free() }
			continue
		}
		if line.contains("'''") || line.contains('```') || line.contains('"""') {
			skipline = !skipline
		}
		if skipline {
			unsafe { line.free() }
			continue
		}
		prev = ''
		word = ''
		skip = false
		splitted_line := line.split('')
		for char in splitted_line {
			if  '[({'.contains(char) {
				skip = true
				continue
			}
			if skip {
				if  ')]}'.contains(char) {
					skip = false
					prev = ''
					continue
				}
			} else {
				if islink {
					if char == ' ' {
						islink = false
					} else {
						continue
					}
				}
				if 'abcdefghijklmnopqrstuvwxyz0123456789_-'.contains(char.to_lower()) {
					if word.len > 0 || prev == '' ||  '\t\n ,:;.?!#|'.contains(prev) {
						word += char
					}
					if word.starts_with('http') {
						islink = true
					}
				} else if '\t\n ,:;.?!#|'.contains(char) {
					// only when end is newline tab or whitespace or ...
					if word.len > 1 && !word_skip(word) && !(word in done) {
						word_with_no_underscores := name_fix_no_underscore(word)
						tr.items << TokenizerItem{
							toreplace: word
							matchstring: word_with_no_underscores.clone()
						}
						done << word
						unsafe { word_with_no_underscores.free() }
					}
					word = ''
					prev = ''
					continue
				} else {
					word = ''
				}
				prev = char
			}
		}
		if word.len > 1 && !word_skip(word) && !(word in done) {
			word_with_no_underscores := name_fix_no_underscore(word)
			tr.items << TokenizerItem{
				toreplace: word
				matchstring: word_with_no_underscores.clone()
			}
			done << word
			unsafe { word_with_no_underscores.free() }
		}
		unsafe { line.free() }
		unsafe { splitted_line.free() }
	}
	return tr
}
