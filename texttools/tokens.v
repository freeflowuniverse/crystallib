module texttools

// import regex

pub struct TokenizerResult {
pub mut:
	items []TokenizerItem
}

pub struct TokenizerItem {
pub mut:
	toreplace string
	// is the most fixed string
	matchstring string
}

pub fn text_token_replace(text string, tofind string, replacewith string) ?string {
	mut tr := tokenize(text)
	text2 := tr.replace(text, tofind, replacewith) ?
	return text2
}


//the map has as key the normalized string (fix_name_no_underscore), the value is what to replace with
pub fn replace_items(text string, replacer map[string]string) ?string {
	mut skipline := false
	mut res := []string{}
	for line_ in text.split('\n') {
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

		//TODO: is very brute force can be done much better
		mut tr := texttools.tokenize(line)
		// println(" ==== $line")
		// println(tr.items)
		for key, replacewith in replacer {
			// println(" == $defname")
			line = tr.replace(line, key, replacewith) ?
			line = tr.replace(line, key+"s",replacewith+"s") ?
		}
		res << line
	}
	return res.join('\n')
}

[manualfree]
pub fn (mut tr TokenizerResult) replace(text string, tofind string, replacewith string) ?string {
	tofind2 := name_fix_no_underscore(tofind)
	defer { unsafe { tofind2.free() } }
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
	mut item := name_fix(name)
	mut newitem := ''               unsafe { newitem.free() }
	newitem = item.replace('_', '') unsafe { item.free() }
	item = newitem
	return item
}

const name_fix_replaces = [
      ' ', '_',
      '-', '_',
      '__', '_',
      '__', '_', /* needs to be 2x because can be 3 to 2 to 1 */
      '::', '_',
      ';', '_',
      ':', '_',
      '.', '_',
]

[manualfree]
pub fn name_fix(name string) string {
	mut item := name.to_lower()
	item = item.replace_each(name_fix_replaces)
	mut newitem := ''                 unsafe { newitem.free() }
	newitem = item.trim(' ._')        unsafe { item.free() } item = newitem
	return item
}

fn word_skip(text string) bool {
	if text.to_lower() in ['the', 'some', 'and', 'plus', 'will', 'do', 'are', 'these'] {
		return true
	}
	return false
}

pub fn tokenize(text_ string) TokenizerResult {
	text := dedent(text_)
	// println(text)
	mut skip := false
	mut skipline := false
	mut prev := ''
	mut word := ''
	mut islink := false
	mut tr := TokenizerResult{}
	mut done := []string{}
	lines := text.split('\n')

	


	for i in 0..lines.len {
		mut line := lines[i].trim(' ')

		if line.trim(' ').starts_with('!') {
			continue
		}

		if line.starts_with('http') {
			continue
		}
		if line.contains("'''") || line.contains('```') || line.contains('"""') {
			skipline = !skipline
		}
		if skipline {
			continue
		}
		prev = ''
		word = ''
		skip = false
		for char in line.split('') {
			if char in '[({' {
				skip = true
				continue
			}
			if skip {
				if char in ')]}' {
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
				if char.to_lower() in 'abcdefghijklmnopqrstuvwxyz0123456789_-' {
					if word.len > 0 || prev == '' || prev in '\t\n ,:;.?!#|' {
						word += char
					}
					if word.starts_with('http') {
						islink = true
					}
				} else if char in '\t\n ,:;.?!#|' {
					// only when end is newline tab or whitespace or ...
					if word.len > 1 && !word_skip(word) && !(word in done) {
						tr.items << TokenizerItem{
							toreplace: word
							matchstring: name_fix_no_underscore(word)
						}
						done << word
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
			tr.items << TokenizerItem{
				toreplace: word
				matchstring: name_fix_no_underscore(word)
			}
			done << word
		}
	}
	return tr
}