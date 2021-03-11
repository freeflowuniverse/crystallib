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

pub fn (mut tr TokenizerResult) replace(text string, tofind string, replacewith string) ?string {
	tofind2 := name_fix_no_underscore(tofind)
	mut text2 := text
	for item in tr.items {
		if item.matchstring == tofind2 {
			// println(' ... $item.matchstring found -> $replacewith')
			text2 = text2.replace(item.toreplace, replacewith)
		}
		// } else {
		// 	println(' ... $item.matchstring !=  $tofind2')
		// }
	}
	return text2
}

pub fn name_fix_no_underscore(name string) string {
	mut item := name_fix(name)
	return item.replace('_', '')
}

pub fn name_fix(name string) string {
	mut item := name.to_lower()
	item = item.replace(' ', '_')
	item = item.replace('-', '_')
	item = item.replace('__', '_')
	item = item.replace('__', '_') // needs to be 2x because can be 3 to 2 to 1
	item = item.replace('::', '_')
	item = item.replace(';', '_')
	item = item.replace(':', '_')
	item = item.replace('.', '_')
	item = item.trim(' ._')
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
	for line in text.split('\n') {
		if line.trim(' ').starts_with('!') {
			continue
		}
		if line.trim(' ').starts_with('http') {
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

// pub fn tokenize2(text string) TokenizerResult {
// 	// println('REGEX: $text')
// 	query := r'[a-zA-Z0-9_]*'
// 	mut r := regex.regex_opt(query) or { panic(err) }
// 	// mut res := []string{}
// 	mut res := TokenizerResult{}
// 	mut word1 := ''
// 	// mut word2 := ""
// 	// mut word3 := ""
// 	mut done := []string{}
// 	// look per line
// 	// aggregate different words per max 3
// 	// calculate the lowest common name (only a...z0...9)
// 	for line in text.split('\n') {
// 		all := r.find_all(line)
// 		// println(all)
// 		mut x := 0
// 		for x < all.len {
// 			word1 = line[all[x]..all[x + 1]]
// 			if '[' in word1 || ']' in word1 {
// 				println(word1)
// 				panic('s')
// 			}
// 			// println("+$word1")
// 			if !(word1 in done) {
// 				res.items << TokenizerItem{
// 					toreplace: word1
// 					matchstring: name_fix_no_underscore(word1)
// 				}
// 				done << word1
// 			}
// 			// if x>1{
// 			// 	word2 = line[all[x-2]..all[x-1]]  + " " + line[all[x]..all[x + 1]] 
// 			// 	// println("++$word2")
// 			// 	if ! (word2 in done){
// 			// 		res.items << TokenizerItem{toreplace:word2,matchstring:name_fix_no_underscore(word2)}
// 			// 		done << word2
// 			// 	}
// 			// }
// 			// if x>2{
// 			// 	word3 = line[all[x-4]..all[x-3]] +" " + line[all[x-2]..all[x-1]] + " " + line[all[x]..all[x + 1]] 
// 			// 	// println("+++$word3")
// 			// 	if ! (word3 in done){
// 			// 		res.items << TokenizerItem{toreplace:word3,matchstring:name_fix_no_underscore(word3)}
// 			// 		done << word3
// 			// 	}
// 			// }
// 			x += 2
// 		}
// 	}
// 	return res
// }
