
module publisher_web
import publisher.config

pub enum SiteType {
	html
	wiki
}

pub struct WebSite {
pub mut:
	name string
	path string
	sitetype  SiteType

}


struct WebServerContext {
pub mut:
	sites  map[string]WebSite   
	config config.ConfigRoot
}

struct Errors {
pub mut:
	site_errors []SiteError
	page_errors map[string][]PageError
}


pub enum SiteErrorCategory {
	duplicatefile
	duplicatepage
	emptypage
	unknown
	sidebar
}

struct SiteError {
pub:
	sitename string
	path  string
	error string
	cat   SiteErrorCategory
}

pub enum SiteState {
	init
	ok
	error
	loaded
}

pub enum PageErrorCat {
	unknown
	brokenfile
	brokenlink
	brokeninclude
	doublepage
}

struct PageError {
pub:
	sitename   string
	path   string 
	line   string
	linenr int
	msg    string
	cat    PageErrorCat
}
