module markdowndocs

import freeflowuniverse.crystallib.texttools

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
	ok
	missing
	error
}

// support for quite some types
pub struct Link {
pub mut:
	// original string //how link was put in the document
	original    string
	content     string
	cat         LinkType
	isexternal  bool // is not linked to a wiki (sites)
	include     bool = true // means we will not link to the remote location, content will be shown in context of local site
	newtab      bool // means needs to be opened on a new tab
	moresites   bool // this means we can look for the content on multiple source sites, site does not have to be specified
	description string
	url         string
	// identification of link:
	filename string // is the name of the page/file where the link points too
	path     string // is path in the site
	site     string // is the sitename where the link points too
	extra    string // e.g. ':size=800x900'
	// internal
	state     LinkState
	error_msg string
	paragraph &Paragraph [str: skip]
}

// return path of the filename in the site
pub fn (mut link Link) pathfull() string {
	mut r := '$link.path/$link.filename'
	r = r.trim_right('/')
	return r
}

fn (mut link Link) error(msg string) {
	link.state = LinkState.error
	link.error_msg = msg
}


// needs to be the relative path in the site, important!
// will return true if there was change
pub fn (mut link Link) link_update(linkpath_new string,save bool) ? {	
	linkpath_old := link.pathfull()
	linkoriginal_old := link.original
	mut linkoriginal_new := linkoriginal_old.replace(linkpath_old,linkpath_new)
	if link.cat == .image{
		//remove description if image, is not needed
		if link.description != ""{
			linkoriginal_new = linkoriginal_new.replace(link.description,"")
			link.description = ""
		}
	}
	if linkoriginal_new != linkoriginal_old{
		link.paragraph.doc.content=link.paragraph.doc.content.replace(linkoriginal_old,linkoriginal_new)
		if save {
			link.paragraph.doc.save()?
		}
		link.paragraph.content.replace(linkoriginal_old,linkoriginal_new)
		link.path = linkpath_new.all_before_last('/')
		link.filename = linkpath_new.all_after_last('/')
		link.original = linkoriginal_new
		link.paragraph.changed = true
	}
}

// return the name of the link
pub fn (mut link Link) name_fix_no_underscore_no_ext() string {
	return texttools.name_fix_no_underscore_no_ext(link.filename)
	// return link.filename.all_before_last('.').trim_right('_').to_lower()
}

// fn (mut o Link) process()?{
// 	return
// }

// fn ( o Link) wiki() string{
// 	return o.content

// }

// fn ( o Link) html() string{
// 	return o.wiki()
// }

// fn ( o Link) str() string{
// 	return "**** Link\n"
// }
