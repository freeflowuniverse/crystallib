import freeflowuniverse.crystallib.books
import markdowndocs

fn test_fix_duplicates() {
	mut sites := books.new()
	test_site := sites.site_new(
		name: 'Test Site'
		path: './example/book1'
	) or {
		panic("Could not create site")
	}

	test_site.fix_duplicates() or {
		panic(err)
	}
}
