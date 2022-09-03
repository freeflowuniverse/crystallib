module markdowndocs

enum LinkType {
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

enum LinkState {
	ok
	missing
	error
}

//support for quite some types
struct Link {
mut:
	// original string //how link was put in the document
	original string	
pub mut:
	content string
	cat         LinkType
	isexternal  bool		//is not linked to a wiki (sites)
	include     bool = true // means we will not link to the remote location, content will be shown in context of local site
	newtab      bool		//means needs to be opened on a new tab
	moresites   bool		//this means we can look for the content on multiple source sites, site does not have to be specified
	description string
	url         string
	// identification of link:
	filename string // is the name of the page/file where the link points too
	path	string //is path in the site
	site     string // is the sitename where the link points too
	extra    string // e.g. ':size=800x900'
	// internal
	state     LinkState
	error_msg string

}


fn (mut link Link) error(msg string) {
	link.state = LinkState.error
	link.error_msg = msg
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


