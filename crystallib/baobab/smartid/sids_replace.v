module smartid

import regex

// find parts of text in form sid:*** till sid:******  .
// replace all occurrences with new sid's which are unique .
// cid = is the circle id for which we find the id's
pub fn sids_replace(txt_ string, cid string) !string {
	mut txt := txt_
	pattern := r'id:[\*]{3,6}[\s$]'
	mut re := regex.regex_opt(pattern) or { panic(err) }
	// re.replace_by_fn(txt,sid_empty_replace_unit)
	for _ in 0 .. 1000 {
		mut words := re.find_all_str(txt)
		if words.len == 0 {
			break // go out of outer loop, means we replaced all
		}
		for mut word in words {
			// now replace the first found one, we can't replace them all
			word2 := word.trim_space() // needed because of regex
			sidnew := sid_new(cid)!
			mut word3 := word.replace(word2, 'sid:${sidnew}') // to maintain line ending
			txt = txt.replace_once(word, word3)
			break // go out of inner loop
		}
	}
	return txt
}

