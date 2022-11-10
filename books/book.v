module books

// import os
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.markdowndocs
import os

enum BookType {
	book
	wiki
	web
}

enum BookState {
	init
	initdone
	scanned
	fixed
	ok
}

pub enum BookErrorCat {
	unknown
	file_not_found
	page_not_found
	site_not_found
	sidebar
}

[heap]
struct BookErrorArgs {
	msg string
	cat BookErrorCat
}

[heap]
struct BookError {
pub mut:
	msg string
	cat BookErrorCat
}

[heap]
pub struct Book {
pub:
	name     string
	booktype BookType
pub mut:
	title  string
	books  &Books            [str: skip] // pointer to books
	pages  map[string]&Page
	files  map[string]&File
	images map[string]&File
	path   Path
	errors []BookError
	book   BookState
	doc    &markdowndocs.Doc [str: skip]
}

pub fn (mut book Book) error(args BookErrorArgs) {
	book.errors << BookError{
		msg: args.msg
		cat: args.cat
	}
}

pub fn (mut book Book) fix() ! {
	for mut item in book.doc.items.filter(it is markdowndocs.Paragraph) {
		if mut item is markdowndocs.Paragraph {
			for mut link in item.links {
				if link.isexternal {
					msge := 'external link not supported yet in summary for:\n $book'
					book.error(cat: .unknown, msg: msge)
				} else {
					$if debug {
						println(' - book $book.name summary:$link.pathfull()')
					}
					sitename := link.path.all_before('/')
					panic("yo $book.books.sites")
					if book.books.sites.exists(sitename) {
						mut site := book.books.sites.get(sitename)!
						dest := '$book.path.path/$sitename'
						site.path.link(dest, true)!

						// now  we can process the page where the link goes to
						pagename := link.filename
						if site.page_exists(pagename) {
							page := site.page_get(pagename)!
							newlink := '[$link.description]($sitename/$page.pathrel)'
							book.pages['$site.name:$page.name'] = page
							if newlink != link.original {
								// $if debug {
								// 	println('change: $link.original -> $newlink')
								// }
								book.doc.content = book.doc.content.replace(link.original,
									newlink)
								book.doc.save()!
							}
						} else {
							book.error(
								cat: .page_not_found
								msg: "Cannot find page:'$pagename' in site:'$sitename'"
							)
							continue
						}
					} else {
						sitenames := book.books.sites.sitenames().join('\n- ')
						book.error(
							cat: .site_not_found
							msg: 'Cannot find site: $sitename \n\nsitenames known::\n\n$sitenames '
						)
						continue
					}
				}
			}
		}
	}
	for key, _ in book.pages {
		mut page := book.pages[key]
		for mut item in page.doc.items.filter(it is markdowndocs.Paragraph) {
			if mut item is markdowndocs.Paragraph { //! interestingly necessary despite filter
				for mut link in item.links {
					if link.cat == .page && page.site.page_exists(link.filename) {
						// println(page.doc)
						pageobj := page.site.page_get(link.filename)!
						book.pages['$pageobj.site.name:$pageobj.name'] = page
					}
					if link.cat == .image && page.site.file_exists(link.filename) {
						fileobj := page.site.file_get(link.filename)!
						book.files['$fileobj.site.name:$fileobj.name'] = fileobj
					}
					if link.cat == .image && page.site.image_exists(link.filename) {
						imageobj := page.site.image_get(link.filename)!
						book.images['$imageobj.site.name:$imageobj.name'] = imageobj
					}
				}
			}
		}
	}

	book.errors_report()!
}

pub fn (mut book Book) errors_report() ! {
	mut p := pathlib.get('$book.path.path/errors.md')
	if book.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors.md')
	p.write(c)!
}

// return path where the book will be created (exported and built from)
pub fn (book Book) book_path(path string) Path {
	dest0 := book.books.config.dest
	return pathlib.get('$dest0/books/$book.name/$path')
}

// return path where the book will be created (exported and built from)
pub fn (book Book) html_path(path string) Path {
	dest0 := book.books.config.dest
	return pathlib.get('$dest0/html/$book.name/$path')
}

// export an mdbook to its html representation
pub fn (mut book Book) mdbook_export() ! {
	book.template_install()! // make sure all required template files are in site
	book_path := book.book_path('').path + '/src'
	html_path := book.html_path('').path
	for key, _ in book.pages {
		mut page := book.pages[key]
		dest := '$book_path/$page.site.name/$page.pathrel'
		println(' - export: $dest')
		page.save(dest)!
	}

	for key2, _ in book.files {
		mut fobj := book.files[key2]
		dest := '$book_path/$fobj.site.name/$fobj.pathrel'
		println(' - export: $dest')
		fobj.copy(dest)!
	}

	for key3, _ in book.images {
		mut iobj := book.images[key3]
		dest := '$book_path/$iobj.site.name/$iobj.pathrel'
		println(' - export: $dest')
		iobj.copy(dest)!
	}

	mut pathsummary := pathlib.get('$book_path/SUMMARY.md')
	// write summary
	pathsummary.write(book.doc.content)!

	// lets now build
	os.execute_or_panic('mdbook build ${book.book_path('').path} --dest-dir $html_path')
	os.execute_or_panic('open $html_path/index.html')
}

fn (mut book Book) template_write(path string, content string) ! {
	mut dest_path := book.book_path(path)
	dest_path.write(content)!
}

fn (mut book Book) template_install() ! {
	if book.title == '' {
		book.title = book.name
	}

	// get embedded files to the mdbook dir
	for item in book.books.embedded_files {
		book_path := item.path.all_after_first('/')
		book.template_write(book_path, item.to_string())!
	}
	c := $tmpl('template/book.toml')
	book.template_write('book.toml', c)!
}
