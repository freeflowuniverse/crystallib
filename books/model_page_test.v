import freeflowuniverse.crystallib.books
import markdowndocs

test_site := site_new({
	name: 'Test Site'
	path: './example/book1'
})

test_page_path := Path{
	path: 'test_page'
	cat: .file
	exists: .yes
}

test_page := site.page_new()

fn test_page_new() {
	assert page.name == 'Test Page'
}

fn test_relocate_img() {
	// test_page := test_page_new()
	// img_link := link_new('original_descr_', 'original_link_', true)
	// page.relocate_img(img_link)
	// assert img_link == ''
}

fn test_fix_img_link() {
}

fn test_fix_file_link() {
}

fn test_fix_external_link() {
}
