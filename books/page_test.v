module books

import os
import freeflowuniverse.crystallib.markdowndocs
import freeflowuniverse.crystallib.pathlib

const testpath = os.dir(@FILE) + '/example/book1'

// const test_page = test_site.page_new()

fn test_fix() {
	mut sites := sites_new()
	mut test_site := sites.site_new(SiteNewArgs{
		name: 'Test Site'
		path: '${books.testpath}'
	}) or { panic('Cannot create new site: ${err}') }
	mut page_path := pathlib.get('${books.testpath}/decentralized_cloud/decentralized_cloud.md')
	mut test_page := test_site.page_new(mut page_path) or { panic('Cannot create page: ${err}') }
	test_page.fix() or { panic('Cannot fix page: ${err}') }
}
