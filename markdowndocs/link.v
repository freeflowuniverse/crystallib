module markdowndocs

import freeflowuniverse.crystallib.texttools
import os

// add link to the page
fn (mut para Paragraph) link_new(original_descr_ string, original_link_ string, isimage bool) !Link {
	mut link := Link{
		// this will be the exact way how the link is done in the paragraph
		original: '[$original_descr_]($original_link_)'
		paragraph: &para
	}
	if isimage {
		link.original = '!' + link.original
		link.cat = LinkType.image
	}
	original_descr := original_descr_.trim(' ')
	original_link := original_link_.trim(' ')

	link.description = original_descr

	if original_link.contains('://') {
		// linkstate = LinkState.ok
		link.isexternal = true
	}

	// if original_link.starts_with('http')
	// 	|| original_link.starts_with('/')
	// 	|| original_link.starts_with('..') {
	// 	link.cat = LinkType.html
	// 	return
	// }

	if original_link.starts_with('http') {
		link.cat = LinkType.html
		return link
	}

	if original_link.starts_with('#') {
		link.cat = LinkType.anchor
		return link
	}

	// AT THIS POINT LINK IS A PAGE OR A FILE
	////////////////////////////////////////

	// deal with special cases where file is not the only thing in ()
	if original_link.contains(' ') {
		// to support something like
		//![](./img/license_threefoldfzc.png ':size=800x900')
		splitted := original_link.trim(' ').split(' ')
		link.filename = splitted[0]
		link.extra = splitted[1]
	} else {
		link.filename = original_link
	}

	if link.filename.contains('/')  {
		link.path = link.filename.all_before_last('/').trim_right('/') // just to make sure it wasn't //
	} else {
		link.path = ''
	}

	// find the prefix
	mut prefix_done := false
	mut filename := []string{}
	for x in link.filename.trim(' ').split('') {
		if !prefix_done {
			if x == '!' {
				link.newtab = true
				continue
			}
			if x == '@' {
				link.include = true
				continue
			}
			if x == '*' {
				link.moresites = true
				continue
			}
		} else {
			prefix_done = true
		}
		filename << x
	}
	link.filename = filename.join('')
	
	// trims prefixes from path
	link.path = link.path.trim_left('!@*') 

	// lets now check if there is site info in there
	if link.filename.contains(':') {
		splitted2 := link.filename.split(':')
		if splitted2.len == 2 {
			link.site = texttools.name_fix(splitted2[0])
			if link.site.starts_with('info_') {
				link.site = link.site[5..]
			}
			link.filename = splitted2[1]
		} else if splitted2.len > 2 {
			link.error('link can only have 1 x ":"/n$link')
			return link
		} else {
			('should never be here')
		}
	}

	// lets strip site info from link path
	link.path = link.path.trim_string_left('$link.site:')

	link.filename = os.base(link.filename)

	if link.path.starts_with('./') {
		x := link.path.after('./')
		link.path = string(x)
	}

	if link.filename != '' {
		link.filename = os.base(link.filename.replace('\\', '/'))

		// check which link type
		ext := os.file_ext(link.filename).trim('.').to_lower()

		if ext == '' {
			link.cat = LinkType.page
			link.filename += '.md'
		} else if ext in ['jpg', 'png', 'svg', 'jpeg', 'gif'] {
			link.cat = LinkType.image
		} else if ext == 'md' {
			link.cat = LinkType.page
		} else if ext in ['html', 'htm'] {
			link.cat = LinkType.html
			return link
		} else if ext in ['v', 'py', 'js', 'c', 'sh'] {
			link.cat = LinkType.code
			return link
		} else if ext in ['doc', 'docx', 'zip', 'xls', 'pdf', 'xlsx', 'ppt', 'pptx'] {
			link.cat = LinkType.file
			return link
		} else if ext in ['json', 'yaml', 'yml', 'toml'] {
			link.cat = LinkType.data
			return link
		} else if original_link.starts_with('mailto:') {
			link.cat = LinkType.email
			return link
		} else if !original_link.contains_any('./!&;') {
			// link.cat = LinkType.page
			panic('need to figure out what to do with $original_link ')
		} else {
			link.error("$original_link (no match), ext was:'$ext'")
			return link
		}

		if link.filename.contains(':') {
			panic("should not have ':' in link for page or file (2).\n$link")
		}
	} else {
		// filename empty
		if !original_link.trim(' ').starts_with('#') {
			link.state = LinkState.error
			link.error('EMPTY LINK.')
			return link
		}
	}

	return link
}

//###########################################################################

// fn (link Link) original_get_with_ignore() string {
// 	mut l := "[$original_descr]($original_link ':ignore')"
// 	if link.isimage {
// 		l = '!$l'
// 	}
// 	return l
// }



// return how to represent link on source
fn (mut link Link) source_get() !string {
	if link.cat == LinkType.image {
		if link.extra == '' {
			return '![$link.description]($link.filename)'
		} else {
			return '![$link.description]($link.filename $link.extra)'
		}
	}
	if link.cat == LinkType.file {
		if link.extra == '' {
			return '[$link.description]($link.filename)'
		} else {
			return '[$link.description]($link.filename $link.extra)'
		}
	}
	if link.cat == LinkType.page {
		if link.filename.contains(':') {
			return error("should not have ':' in link for page or file.\n$link")
		}

		mut link_filename := link.filename

		if link.site != '' {
			link_filename = '$link.site:$link_filename'
		}
		if link.include == false {
			link_filename = '@$link_filename'
		}
		if link.newtab {
			link_filename = '!$link_filename'
		}

		return '[$link.description]($link_filename)'
	}
	return link.original
}

// replace original link content in text with $replacewith
// if replacewith is empty then will recreate the link as source_get()!
pub fn (mut link Link) replace(text string, replacewith_ string) !string {
	mut replacewith:=replacewith_
	if replacewith==""{
		replacewith = link.source_get()!
	}
	return text.replace(link.original, replacewith)
}


enum LinkParseStatus {
	start
	linkopen
	link
	comment
}

struct LinkParseResult {
pub mut:
	links []Link
}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// returns all the links
pub fn (mut para Paragraph) link_parser(text string) !LinkParseResult {
	mut charprev := ''
	mut ch := ''
	mut state := LinkParseStatus.start
	mut capturegroup_pre := '' // is in the []
	mut capturegroup_post := '' // is in the ()
	mut parseresult := LinkParseResult{}
	mut isimage := false
	// no need to process files which are not at least 2 chars
	if text.len > 2 {
		charprev = ''
		for i in 0 .. text.len {
			ch = text[i..i + 1]
			// check for comments end
			if state == LinkParseStatus.comment {
				if text[i - 3..i] == '-->' {
					state = LinkParseStatus.start
					capturegroup_pre = ''
					capturegroup_post = ''
				}
				// check for comments start
			} else if i > 3 && text[i - 4..i] == '<!--' {
				state = LinkParseStatus.comment
				capturegroup_pre = ''
				capturegroup_post = ''
				// check for end in link or file			
			} else if state == LinkParseStatus.linkopen {
				// original += ch
				if charprev == ']' {
					// end of capture group
					// next char needs to be ( otherwise ignore the capturing
					if ch == '(' {
						if state == LinkParseStatus.linkopen {
							// remove the last 2 chars: ](  not needed in the capturegroup
							state = LinkParseStatus.link
							capturegroup_pre = capturegroup_pre[0..capturegroup_pre.len - 1]
						} else {
							state = LinkParseStatus.start
							capturegroup_pre = ''
						}
					} else {
						// cleanup was wrong match, was not file nor link
						state = LinkParseStatus.start
						capturegroup_pre = ''
					}
				} else {
					capturegroup_pre += ch
				}
				// is start, check to find links	
			} else if state == LinkParseStatus.start {
				if ch == '[' {
					if charprev == '!' {
						isimage = true
					}
					state = LinkParseStatus.linkopen
				}
				// check for the end of the link/file
			} else if state == LinkParseStatus.link {
				// original += ch
				if ch == ')' {
					// end of capture group
					mut link := para.link_new(capturegroup_pre, capturegroup_post, isimage)!
					// remember the consumer page
					parseresult.links << link
					capturegroup_pre = ''
					capturegroup_post = ''
					isimage = false
					state = LinkParseStatus.start
				} else {
					capturegroup_post += ch
				}
			}
			charprev = ch // remember the previous one
		}
	}
	return parseresult
}
