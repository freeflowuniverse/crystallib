module publisher

enum ParseStatus {
	start
	linkopen
	link
	comment
}

struct ParseResult {
pub mut:
	links []Link
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// returns all the links
pub fn link_parser(mut publisher Publisher, mut page Page, text string) ?ParseResult {
	mut charprev := ''
	mut ch := ''
	mut state := ParseStatus.start
	mut capturegroup_pre := '' // is in the []
	mut capturegroup_post := '' // is in the ()
	mut parseresult := ParseResult{}
	mut isimage := false
	// no need to process files which are not at least 2 chars
	if text.len > 2 {
		charprev = ''
		for i in 0 .. text.len {
			ch = text[i..i + 1]
			// check for comments end
			if state == ParseStatus.comment {
				if text[i - 3..i] == '-->' {
					state = ParseStatus.start
					capturegroup_pre = ''
					capturegroup_post = ''
				}
				// check for comments start
			} else if i > 3 && text[i - 4..i] == '<!--' {
				state = ParseStatus.comment
				capturegroup_pre = ''
				capturegroup_post = ''
				// check for end in link or file			
			} else if state == ParseStatus.linkopen {
				// original += ch
				if charprev == ']' {
					// end of capture group
					// next char needs to be ( otherwise ignore the capturing
					if ch == '(' {
						if state == ParseStatus.linkopen {
							// remove the last 2 chars: ](  not needed in the capturegroup
							state = ParseStatus.link
							capturegroup_pre = capturegroup_pre[0..capturegroup_pre.len - 1]
						} else {
							state = ParseStatus.start
							capturegroup_pre = ''
						}
					} else {
						// cleanup was wrong match, was not file nor link
						state = ParseStatus.start
						capturegroup_pre = ''
					}
				} else {
					capturegroup_pre += ch
				}
				// is start, check to find links	
			} else if state == ParseStatus.start {
				if ch == '[' {
					if charprev == '!' {
						isimage = true
					}
					state = ParseStatus.linkopen
				}
				// check for the end of the link/file
			} else if state == ParseStatus.link {
				// original += ch
				if ch == ')' {
					// end of capture group
					mut link := link_new(mut publisher, capturegroup_pre.trim(' '), capturegroup_post.trim(' '),
						isimage, &page)?
					// remember the consumer page
					parseresult.links << link
					capturegroup_pre = ''
					capturegroup_post = ''
					isimage = false
					state = ParseStatus.start
				} else {
					capturegroup_post += ch
				}
			}
			charprev = ch // remember the previous one
		}
	}
	return parseresult
}
