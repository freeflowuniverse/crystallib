module books

import freeflowuniverse.crystallib.pathlib

pub fn sites_new() Sites {
	mut sites := Sites{}
	sites.config = SitesConfig{}
	return sites
}

pub fn books_new(sites &Sites) Books {
	mut books := Books{
		sites: sites
	}
	books.config = BooksConfig{}
	return books
}
