import freeflowuniverse.crystallib.books { new }

const path = '~/code/github/threefoldfoundation/books/content/abundance_internet'

fn test_scan_internal() {
	sites := new()
	site_args := SiteNewArgs {
		name: TestSite
		path: path
	}
	site := sites.new_site(site_args)
	site.scan()
}
