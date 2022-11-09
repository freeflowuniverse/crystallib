import freeflowuniverse.crystallib.books { sites_new }

const path = '~/code/github/threefoldfoundation/books/content/abundance_internet'

fn test_scan_internal() {
	mut sites := sites_new()
	site_args := books.SiteNewArgs {
		name: 'TestSite'
		path: path
	}
	mut site := sites.site_new(site_args) or { panic('Error creating site: $err') }
	site.scan() or { panic('Error scanning site: $err') }
}
