module knowledgetree

//TODO: needs serious fixes

// import os
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.markdowndocs
import freeflowuniverse.crystallib.texttools
import v.embed_file
import os

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
	image_not_found
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
pub struct MDBook {
pub:
	tree  	 &Tree            [str: skip]
pub mut:
	name     string
	path   string //path exists
	dest   string //path where book will be generated		
	title       string
	pages       map[string]&Page  //links to the object in tree
	files       map[string]&File
	images      map[string]&File
	path        Path
	errors      []BookError
	state        BookState
	doc_summary  &markdowndocs.Doc [str: skip]
}

pub fn (mut book MDBook) error(args BookErrorArgs) {
	book.errors << BookError{
		msg: args.msg
		cat: args.cat
	}
}


[params]
pub struct BookNewArgs {
pub:
	name   string [required] //name of the book
	path   string //path exists
	dest   string //path where book will be generated
	git_url   string
	git_reset bool
	git_root  string //in case we want to checkout code on other location
	git_pull  bool	
}


pub fn (mut l Tree) book_new(args_ BookNewArgs) !&MDBook {
	mut args := args_
	args.name = texttools.name_fix_no_underscore_no_ext(args.name)
	if args.name == '' {
		return error('Cannot specify new book without specifying a name.')
	}

	if args.git_url.len > 0 {
		mut gs := gittools.get(root: args.git_root)!
		mut gr := gs.repo_get_from_url(url: args.git_url, pull: args.git_pull, reset: args.git_reset)!
		args.path = gr.path_content_get()
	}

	if args.path.len < 3 {
		return error('Path needs to be not empty.')
	}	


	mut p := pathlib.get_file(path, false)! // makes sure we have the right path
	if !p.exists() {
		return error('cannot find book on path: ${args.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper


	mut b := MDBook{
		name: args.name
		tree: &l
		path: args.path
		dest: args.dest
	}
	l.books[args.name] = &b

	return l.books[args.name] or { panic('bug') }
	
}


// fix summary (this means summary will put the )
// walk over pages find broken links
// report on the errors
pub fn (mut book MDBook) fix() ! {
	// book.fix_summary()!
	// book.link_pages_files_images()!
	// TODO: check the links on pages
	// book.errors_report()!
}



// reset all, just to make sure we regenerate fresh
pub fn (mut mdbook MDBook) reset() ! {
	// delete where the mdbook are created
	for item in ['mdbook', 'html'] {
		mut a := pathlib.get(mdbook.config.dest + '/${item}')
		a.delete()!
	}
	mdbook.state = .init // makes sure we re-init
	mdbook.init()!
}


// fixes the summary doc for the book
fn (mut book MDBook) fix_summary() ! {
	for mut paragraph in book.doc_summary.items.filter(it is markdowndocs.Paragraph) {
		if mut paragraph is markdowndocs.Paragraph {
			for mut item in paragraph.items {
				if mut item is markdowndocs.Link {
					mut link := item
					if link.isexternal {
						msge := 'external link not supported yet in summary for:\n ${book}'
						book.error(cat: .unknown, msg: msge)
					} else {
						$if debug {
							println(' - book ${book.name} summary:${link.pathfull()}')
						}
						mut sitename := link.path.all_before('/')
						if link.path == '' {
							// means site has not been specified
							return error('site needs to be specified in summary, is the first part of path e.g. sitename/...')
						}
						if book.books.sites.exists(sitename) {
							mut site := book.books.sites.get(sitename)!
							dest := '${book.path.path}/${sitename}'
							site.path.link(dest, true)!

							// now  we can process the page where the link goes to
							pagename := link.filename
							if site.page_exists(pagename) {
								page := site.page_get(pagename)!
								newlink := '[${link.description}](${sitename}/${page.pathrel})'
								book.pages['${site.name}:${page.name}'] = page
								if newlink != link.content {
									// $if debug {
									// 	println('change: $link.content -> $newlink')
									// }
									paragraph.content = paragraph.content.replace(link.content,
										newlink)
									// paragraph.doc.save_wiki()!
									panic('not implemented save wiki')
								}
							} else {
								book.error(
									cat: .page_not_found
									msg: "Cannot find page:'${pagename}' in site:'${sitename}'"
								)
								continue
							}
						} else {
							sitenames := book.books.sites.sitenames().join('\n- ')
							book.error(
								cat: .site_not_found
								msg: 'Cannot find site: ${sitename} \n\nsitenames known::\n\n${sitenames} '
							)
							continue
						}
					}
				}
			}
		}
	}
}

// all images, files and pages found need to be linked to the book
// find which files,pages, images are not found
fn (mut book MDBook) link_pages_files_images() ! {
	for _, mut page in book.pages {
		for mut paragraph in page.doc.items.filter(it is markdowndocs.Paragraph) {
			if mut paragraph is markdowndocs.Paragraph {
				for mut item in paragraph.items {
					if mut item is markdowndocs.Link {
						mut link := item
						if link.cat == .page {
							pageobj := page.site.page_get(link.filename) or {
								book.error(
									cat: .page_not_found
									msg: 'Cannot find page: ${link.filename} in ${page.name}'
								)
								continue
							}
							book.pages['${pageobj.site.name}:${pageobj.name}'] = pageobj
						}
						if link.cat == .file {
							fileobj := page.site.file_get(link.filename) or {
								book.error(
									cat: .file_not_found
									msg: 'Cannot find file: ${link.filename} in ${page.name}'
								)
								continue
							}
							book.files['${fileobj.site.name}:${fileobj.name}'] = fileobj
						}
						if link.cat == .image {
							imageobj := page.site.image_get(link.filename) or {
								book.error(
									cat: .image_not_found
									msg: 'Cannot find image: ${link.filename} in ${page.name}'
								)
								continue
							}
							book.images['${imageobj.site.name}:${imageobj.name}'] = imageobj
						}
					}
				}
			}
		}
	}
}

pub fn (mut book MDBook) errors_report() ! {
	mut p := pathlib.get('${book.path.path}/errors.md')
	if book.errors.len == 0 {
		p.delete()!
		return
	}
	c := $tmpl('template/errors.md')
	p.write(c)!
}

// return path where the book will be created (exported and built from)
fn (book MDBook) book_path(path string) Path {
	dest0 := book.books.config.dest
	return pathlib.get('${dest0}/books/${book.name}/${path}')
}

// return path where the book will be created (exported and built from)
fn (book MDBook) html_path(path string) Path {
	dest0 := book.books.config.dest
	return pathlib.get('${dest0}/html/${book.name}/${path}')
}

// export an mdbook to its html representation
pub fn (mut book MDBook) export() ! {
	book.template_install()! // make sure all required template files are in site
	book_path := book.book_path('').path + '/src'
	html_path := book.html_path('').path
	for _, mut page in book.pages {
		dest := '${book_path}/${page.site.name}/${page.pathrel}'
		println(' - export: ${dest}')
		page.save(dest)!
	}

	for _, mut file in book.files {
		dest := '${book_path}/${file.site.name}/${file.pathrel}'
		println(' - export: ${dest}')
		file.copy(dest)!
	}

	for _, mut image in book.images {
		dest := '${book_path}/${image.site.name}/${image.pathrel}'
		println(' - export: ${dest}')
		image.copy(dest)!
	}

	mut pathsummary := pathlib.get('${book_path}/SUMMARY.md')
	// write summary
	pathsummary.write(book.doc_summary.wiki())!

	// lets now build
	os.execute_or_panic('mdbook build ${book.book_path('').path} --dest-dir ${html_path}')
	os.execute_or_panic('open ${html_path}/index.html')
}

fn (mut book MDBook) template_write(path string, content string) ! {
	mut dest_path := book.book_path(path)
	dest_path.write(content)!
}

fn (mut book MDBook) template_install() ! {
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
