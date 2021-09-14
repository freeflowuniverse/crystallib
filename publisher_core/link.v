module publisher_core

import despiegk.crystallib.texttools
import os

enum ParseStatus {
	start
	linkopen
	link
	comment
}

enum LinkType {
	file
	page
	unknown
	html
	data
	email
	anchor
	code	
}

enum LinkState {
	ok
	missing
	error
}

struct ParseResult {
pub mut:
	links []Link
}

struct Link {
	// original string //how link was put in the document
	original_descr string // when we want to replace
mut:
	original_link  string
pub mut:
	path		string
	isexternal  bool
	newtab		bool
	cat         LinkType
	isimage     bool // means started with !
	description string
	filename    string // no : inside for site definition
	url         string
	site        string
	state       LinkState
	extra       string // e.g. ':size=800x900'
	error_msg   string
	page_file_id 	int = 999999  //is the id of the page where the link is
	consumer_page_id int = 999999 //is the id of the page which has the link
}

fn link_new(mut publisher &Publisher, original_descr string, original_link string, isimage bool,consumer_page_id int ) Link {
	mut link := Link{
		original_descr: original_descr.trim(' ')
		original_link: original_link.trim(' ')
		isimage: isimage
		consumer_page_id: consumer_page_id
	}
	link.init_(mut publisher)
	return link
}

fn (link Link) original_get() string {
	mut l := '[$link.original_descr]($link.original_link)'
	if link.isimage {
		l = '!$l'
	}
	return l
}

// return how to represent link on server
// page is the page from where the link is on
fn (mut link Link) server_get(mut publisher &Publisher) string {
	
	if link.cat == LinkType.page {
		mut page_source := link.page_source_get(mut publisher) or { panic(err) }
		// mut page := link.page_link_get(mut publisher &Publisher)
		if link.newtab == false {
			if page_source.sidebarid > 0 && link.filename.to_lower()!="readme" {
				// return '[$link.description](${link.site}__${link.filename}.md)'	

				mut page_sidebar := page_source.sidebar_page_get(mut publisher) or { panic(err) }
				mut path_sidebar := page_sidebar.path_dir_relative_get(mut publisher).trim(" /")

				if page_source.name == "sidebar"{
					println(" - serverget: path_sidebar:$path_sidebar $link.filename")	
				}

				// println(" - serverget: path_sidebar:$path_sidebar $link.filename")

				if path_sidebar != ""{
					site := page_source.site_get(mut publisher) or { panic(err) }
					if link.site != site.name{
						return '<a href="/info/${link.site}/#/$path_sidebar/$link.filename"> $link.description </a>'
					}else{
						return '[$link.description](/$path_sidebar/${link.filename}.md)'	
					}
				}
			}
			// return '<a href="/info/${link.site}/#/$link.filename"> $link.description </a>'
			return '[$link.description](${link.site}__${link.filename}.md)'	
		}else{
			// return '[$link.description](/${link.site}/${link.filename}.md \':target=_blank\')'
			return '<a href="/info/${link.site}/#/$link.filename" target="_blank"> $link.description </a>'
		}
		
	}
	if link.cat == LinkType.file {
		if link.isimage {
			// return '![$link.description](${link.site}__$link.filename  $link.extra)'
			if link.extra==""{
				return '![$link.description]($link.filename)'
			}else{
				return '![$link.description]($link.filename $link.extra)'
			}
			
		}
		// return '[$link.description](/${link.site}__$link.filename  $link.extra)'
		if link.extra == '' {
			return '<a href="${link.site}__$link.filename"> $link.description </a>'
		} else {
			return '<a href="${link.site}__$link.filename $link.extra"> $link.description </a>'
		}
	}
	return link.original_get()
}

// return how to represent link on source
fn (mut link Link) source_get(sitename string) string {
	// println(" >>< $sitename $link.site")
	if link.cat == LinkType.page {
		if link.filename.contains(':') {
			panic("should not have ':' in link for page or file.\n$link")
		}
		if sitename == link.site {
			return '[$link.description]($link.filename)'
		} else {
			return '[$link.description]($link.site:$link.filename)'
		}
	}
	if link.cat == LinkType.file {
		if link.filename.contains(':') {
			panic('should not have in link for page or file.\n$link')
		}
		mut filename := ''

		if link.isimage {
			filename = 'img/$link.filename'
		} else {
			filename = '$link.filename'
		}

		mut j := ''

		if link.extra == '' {
			j = '[$link.description]($filename)'
		} else {
			j = '[$link.description]($filename $link.extra)'
		}

		if link.isimage {
			j = '!$j'
		}

		return j
	}
	return link.original_get()
}

// replace original link content in text with $replacewith
fn (link Link) replace(text string, replacewith string) string {
	return text.replace(link.original_get(), replacewith)
}

fn (mut link Link) init_(mut publisher &Publisher) {
	// see if its an external link or internal
	// mut linkstate := LinkState.init
	if link.original_link.contains('://') {
		// linkstate = LinkState.ok
		link.isexternal = true
	}

	if link.original_link.trim(' ').starts_with('#') {
		link.cat = LinkType.anchor
		return
	}

	if link.original_link.trim(' ').starts_with('!') {
		link.newtab = true
	}

	if link.original_link.trim(' ').starts_with('http')
		|| link.original_link.trim(' ').starts_with('/')
		|| link.original_link.trim(' ').starts_with('..') {
		link.cat = LinkType.html
		return
	}
	// deal with special cases where file is not the only thing in ()
	if link.original_link.contains(' ') {
		// to support something like
		//![](./img/license_threefoldfzc.png ':size=800x900')
		splitted := link.original_link.split(' ')
		link.filename = splitted[0]
		link.extra = splitted[1]
	} else {
		link.filename = link.original_link
	}

	if link.original_link.starts_with('mailto:') {
		link.cat = LinkType.email
		return
	}

	if link.filename != '' {
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
				link.state = LinkState.error
				link.error_msg = 'link can only have 1 x ":"/n$link'
				link.state = LinkState.error
			} else {
				panic('should never be here')
			}
		}

		link.filename = link.filename.replace('\\', '/')

		link.filename = link.filename.after('!')

		base_of_link_filename := os.base(link.filename)
		fixed_name := texttools.name_fix(base_of_link_filename)
		fixed_name_lower := fixed_name.to_lower()
		fixed_name_lower_trimmed := fixed_name_lower.trim('.')
		link.filename = fixed_name_lower_trimmed

		// check which link type
		ext := os.file_ext(link.filename).trim('.')

		// if link.filename.ends_with("}"){
		// 	println(link)
		// 	panic("a")
		// }

		if ext == '' {
			link.cat = LinkType.page
		} else if ext in ['jpg', 'png', 'svg', 'jpeg', 'gif'] {
			link.isimage = true
			link.cat = LinkType.file
		} else if ext == 'md' {
			panic('should not happen')
			// link.cat = LinkType.page
		} else if ext in ['html', 'htm'] {
			link.cat = LinkType.html
		} else if ext in ['v', 'py', 'js', 'c', 'sh'] {
			link.cat = LinkType.code
		} else if ext in ['doc', 'docx', 'zip', 'xls', 'pdf', 'xlsx', 'ppt', 'pptx'] {
			link.cat = LinkType.file
		} else if ext in ['json', 'yaml', 'yml', 'toml'] {
			link.cat = LinkType.data
		} else if (!link.original_link.contains_any('./?&;')) && !link.isimage {
			// link.cat = LinkType.page
			panic('need to figure out what to dow with $link.original_link ')
		} else {
			// should be a page if no extension
			// link.cat = LinkType.page
			link.state = LinkState.error
			link.error_msg = "$link.original_link (no match), ext was:'$ext'"
			link.state = LinkState.error
		}


		if link.cat == LinkType.page {
			mut linktocheck := link.original_link
			if linktocheck.starts_with("!"){
				linktocheck = linktocheck.after('!')
			}
			item_linked := publisher.page_find(linktocheck, link.consumer_page_id) or {
				link.state = LinkState.error
				link.error_msg = 'link, cannot find page: ${link.original_link}.\n$err'
				link.state = LinkState.error
				return
			}
			link.page_file_id = item_linked.id
			link.site = item_linked.site_name_get(mut publisher)
		}else if link.cat == LinkType.file {
			mut linktocheck := link.original_link
			item_linked := publisher.file_check_find(linktocheck, link.consumer_page_id) or {
				link.state = LinkState.error
				link.error_msg = 'link, cannot find file: ${link.original_link}.\n$err'
				link.state = LinkState.error
				return
			}
			link.page_file_id = item_linked.id
			link.site = item_linked.site_name_get(mut publisher)
		}

		if link.original_link.starts_with("*"){
			link.filename = link.filename.all_after('*')
			//don't replace original link name, otherwise will not replace
		}

		

		// if link.original_link.starts_with("!"){
		// 	println(link)
		// 	panic("a")
		// }		

		if link.filename.contains(':') {
			panic("should not have ':' in link for page or file (2).\n$link")
		}
	}
}

//get the page where is linked too
pub fn (mut link Link) page_link_get(mut publisher &Publisher) ?&Page{
	if link.page_file_id==0{
		return error("consumer page_link id cannot be 0./n$link")
	}
	if link.cat == LinkType.page {
		return publisher.page_get_by_id(link.page_file_id)
	}
	return error("can only return Page")
}

//get the page which has the link
pub fn (mut link Link) page_source_get(mut publisher &Publisher) ?&Page{
	if link.consumer_page_id==0{
		return error("page_link id cannot be 0./n$link")
	}
	if link.cat == LinkType.page {
		return publisher.page_get_by_id(link.consumer_page_id)
	}
	return error("can only return Page")
}

fn (mut link Link) file_get(mut publisher &Publisher) ?&File{
	if link.page_file_id==0{
		return error("file id cannot be 0./n$link")
	}
	if link.cat == LinkType.file {
		return publisher.file_get_by_id(link.page_file_id)
	}
	return error("can only return File")
}


// used by the line processor on page (page walks over content line by line to parts links, 
fn (mut link Link) check(mut publisher &Publisher, mut page Page, linenr int, line string) {
	// mut filename_complete := ''
	// mut site := &publisher.sites[page.site_id]

	link.description = link.original_descr

	// filename_complete = '$link.site:$link.filename'

	if link.cat in [LinkType.file, LinkType.page] {
		// check if there are pagename or sitename changes
		if link.site != '' {
			sitename_replaced := publisher.replacer.site.replace(text:link.site) or { panic(err) }
			if link.site != sitename_replaced {
				link.site = sitename_replaced
			}
		}
		filename_replaced := publisher.replacer.file.replace(text:link.filename) or { panic(err) }
		if link.filename != filename_replaced {
			link.filename = filename_replaced
		}
	}
	// this can't work, no idea what to do with this, lets see TODO:
	if link.cat == LinkType.html {
		// splitted := link.link.split(" ")
		// mut l := "html__${sitename}__" + splitted[0].replace("/", "__")				
		// if splitted.len > 1{
		// 	l = l + " " + splitted[1 ..].join(" ")
		// }
		return
	}

	if link.cat == LinkType.email {
		return
	}

	if link.cat == LinkType.anchor {
		return
	}

	if link.filename == '' {
		if !link.original_link.trim(' ').starts_with('#') {
			link.state = LinkState.error
			link.error_msg = "EMPTY LINK: for '$link.original_get()'"
			return
		}
	}

}

// DO NOT CHANGE THE WAY HOW THIS WORKS, THIS HAS BEEN DONE AS A STATEFUL PARSER BY DESIGN
// THIS ALLOWS FOR EASY ADOPTIONS TO DIFFERENT REALITIES
// returns all the links
pub fn link_parser(mut publisher &Publisher,text string, consumer_page_id int) ParseResult {
	mut charprev := ''
	mut char := ''
	mut state := ParseStatus.start
	mut capturegroup_pre := '' // is in the []
	mut capturegroup_post := '' // is in the ()
	mut parseresult := ParseResult{}
	mut isimage := false
	// no need to process files which are not at least 2 chars
	if text.len > 2 {
		charprev = ''
		for i in 0 .. text.len {
			char = text[i..i + 1]
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
				// original += char
				if charprev == ']' {
					// end of capture group
					// next char needs to be ( otherwise ignore the capturing
					if char == '(' {
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
					capturegroup_pre += char
				}
				// is start, check to find links	
			} else if state == ParseStatus.start {
				if char == '[' {
					if charprev == '!' {
						isimage = true
					}
					state = ParseStatus.linkopen
				}
				// check for the end of the link/file
			} else if state == ParseStatus.link {
				// original += char
				if char == ')' {
					// end of capture group
					mut link := link_new(mut publisher, capturegroup_pre.trim(' '), 
						capturegroup_post.trim(' '),isimage,consumer_page_id )
					//remember the consumer page
					parseresult.links << link
					capturegroup_pre = ''
					capturegroup_post = ''
					isimage = false
					state = ParseStatus.start
				} else {
					capturegroup_post += char
				}
			}
			charprev = char // remember the previous one
		}
	}
	return parseresult
}
