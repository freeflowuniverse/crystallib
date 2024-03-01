module elements

import freeflowuniverse.crystallib.core.texttools
import os

@[heap]
pub struct Link {
	DocBase
pub mut:
	cat         LinkType
	isexternal  bool // is not linked to a wiki (sites)
	include     bool // means we will not link to the remote location, content will be shown in context of local site
	newtab      bool // means needs to be opened on a new tab
	moresites   bool // this means we can look for the content on multiple source sites, site does not have to be specified
	description string
	url         string
	// identification of link:
	filename string // is the name of the page/file where the link points too
	path     string // is path in the site
	site     string // is the sitename where the link points too (collection)
	extra    string // e.g. ':size=800x900'
	// internal
	state     LinkState
	error_msg string
}

pub enum LinkType {
	file
	image
	page
	unknown
	html
	data
	email
	anchor
	code
}

pub enum LinkState {
	init //the original state (prob means already processed)
	linkprocessed //means we have found the original information
	missing
	error
}

pub fn (mut self Link) process() !int {
	if self.processed {
		return 0
	}
	self.trailing_lf = false
	self.parse()
	self.processed = true
	self.content = ""
	return 1
}

fn (self Link) markdown_include() string {

	println(" ----- LINK MARKDOWN INCLUDE ${self.url} ${self.cat}")

	pd:=self.parent_doc_ or {panic("bug there should always be parent_doc")}

	mut link_filename := self.filename

	if self.site != '' {
		link_filename = '${self.site}:${link_filename}'
	}else if pd.collection_name!='' {
		link_filename = '${pd.collection_name}:${link_filename}'
			}
	
	mut out := ''

	if self.cat == LinkType.page || self.cat == LinkType.file || self.cat == LinkType.image || self.cat == LinkType.code{
		mut pre := ''
		if self.cat == LinkType.file || self.cat == LinkType.image{
			pre = '!'
		}

		if self.extra.trim_space() == '' {
			out = '${pre}[${self.description}](${link_filename})'
		} else {
			out = '${pre}[${self.description}](${link_filename} ${self.extra})'
		}
	}else if self.cat == LinkType.html || self.cat == LinkType.anchor || self.cat == LinkType.data{
		out = '[${self.description}](${self.url})'
	}else{
		panic("bug")
	}
	return out
}

pub fn (self Link) markdown() !string {

	if self.state == .init{
		//means we need to give link before it was processed to resolve the link e.g. in doctree
		return self.markdown_include()
	}
	
	mut link_filename := self.filename

	mut out := ''
	if self.cat == LinkType.page || self.cat == LinkType.file || self.cat == LinkType.image {
		if self.filename.contains(':') {
			return error("should not have ':' in link for image, page or file.\n${self}")
		}
		if self.path != '' {
			link_filename = '${self.path}/${link_filename}'
		}
		if self.extra.trim_space() == '' {
			out = '![${self.description}](${link_filename})'
		} else {
			out = '![${self.description}](${link_filename} ${self.extra})'
		}
	}else if self.cat == LinkType.html {
		out = '[${self.description}](${self.url})'
	}else{
		panic("bug")
	}

	// if self.cat == LinkType.page {

	// 	// if self.include {
	// 	// 	link_filename = '@${link_filename}'
	// 	// }
	// 	// if self.newtab {
	// 	// 	link_filename = '!${link_filename}'
	// 	// }
	// 	// if self.moresites {
	// 	// 	link_filename = '*${link_filename}'
	// 	// }

	// 	out = '[${self.description}](${link_filename})'
	// }

	return out
}

pub fn (self Link) html() !string {
	panic('implement')
	// TODO: implement	
	return ''
}

pub fn (self Link) pug() !string {
	return error("cannot return pug, not implemented")
}


// return path of the filename in the site
pub fn (mut link Link) pathfull() string {
	mut r := '${link.path}/${link.filename}'
	r = r.trim_left('/')
	return r
}

fn (mut link Link) error(msg string) {
	link.state = LinkState.error
	link.error_msg = msg
}

// return the name of the link
pub fn (mut link Link) name_fix_no_underscore_no_ext() string {
	return texttools.name_fix_no_underscore_no_ext(link.filename)
	// return link.filename.all_before_last('.').trim_right('_').to_lower()
}

fn (mut link Link) parse() {
	link.content = link.content.trim_space()
	if link.content.starts_with('!') {
		link.cat = LinkType.image
	}

	link.description = link.content.all_after('[').all_before(']').trim_space()
	link.url = link.content.all_after('(').all_before(')').trim_space()
	if link.url.contains('://') {
		// linkstate = LinkState.ok
		link.isexternal = true
	}

	// if link.url.starts_with('http')
	// 	|| link.url.starts_with('/')
	// 	|| link.url.starts_with('..') {
	// 	link.cat = LinkType.html
	// 	return
	// }

	if link.url.starts_with('http') {
		link.cat = LinkType.html
		return
	}

	if link.url.starts_with('#') {
		link.cat = LinkType.anchor
		return
	}

	// AT THIS POINT LINK IS A PAGE OR A FILE
	////////////////////////////////////////

	link.url = link.url.trim_left(' ')

	// deal with special cases where file is not the only thing in ()
	if link.url.trim(' ').contains(' ') {
		// to support something like
		//![](./img/license_threefoldfzc.png ':size=800x900')
		splitted := link.url.trim(' ').split(' ')
		link.filename = splitted[0]
		link.extra = splitted[1]
	} else {
		link.filename = link.url.trim(' ')
	}

	if link.filename.contains('/') {
		link.path = link.filename.all_before_last('/').trim_right('/') // just to make sure it wasn't //
	} else {
		link.path = ''
	}

	// // find the prefix
	// mut prefix_done := false
	// mut filename := []string{}
	// for x in link.filename.trim(' ').split('') {
	// 	if !prefix_done {
	// 		if x == '!' {
	// 			link.newtab = true
	// 			continue
	// 		}
	// 		if x == '@' {
	// 			link.include = true
	// 			continue
	// 		}
	// 		if x == '*' {
	// 			link.moresites = true
	// 			continue
	// 		}
	// 	} else {
	// 		prefix_done = true
	// 	}
	// 	filename << x
	// }
	// link.filename = filename.join('')

	// // trims prefixes from path
	// link.path = link.path.trim_left('!@*')

	// lets now check if there is site info in there
	if link.filename.contains(':') {
		splitted2 := link.filename.split(':')
		if splitted2.len == 2 {
			link.site = texttools.name_fix(splitted2[0])
			// if link.site.starts_with('info_') {
			// 	link.site = link.site[5..]
			// }
			link.filename = splitted2[1]
		} else if splitted2.len > 2 {
			link.error('link can only have 1 x ":"/n${link}')
			return
		} else {
			('should never be here')
		}
	}
	if link.site.contains('/') {
		link.site = link.site.all_after_last('/')
	}

	link.filename = os.base(link.filename).replace('\\', '/')

	if link.path.starts_with('./') {
		link.path = link.path.after('./')
	}

	if link.filename != '' {
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
			return
		} else if ext in ['v', 'py', 'js', 'c', 'sh'] {
			link.cat = LinkType.code
			return
		} else if ext in ['doc', 'docx', 'zip', 'xls', 'pdf', 'xlsx', 'ppt', 'pptx'] {
			link.cat = LinkType.file
			return
		} else if ext in ['json', 'yaml', 'yml', 'toml'] {
			link.cat = LinkType.data
			return
		} else if link.url.starts_with('mailto:') {
			link.cat = LinkType.email
			return
		} else if !link.url.contains_any('./!&;') {
			// link.cat = LinkType.page
			panic('need to figure out what to do with ${link.url} ')
		} else {
			link.error("${link.url} (no match), ext was:'${ext}'")
			return
		}
		if link.filename.contains(':') {
			panic("should not have ':' in link for page or file (2).\n${link}")
		}
	} else {
		// filename empty
		if !link.url.trim(' ').starts_with('#') {
			link.state = LinkState.error
			link.error('EMPTY LINK.')
			return
		}
	}
}
