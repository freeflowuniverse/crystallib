module knowledgetree

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.markdowndocs
import freeflowuniverse.crystallib.pathlib { Path }
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.osal

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
	collection_not_found
	collection_error
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
pub mut:
	tree        &Tree             [str: skip]
	name        string
	dest        string // path where book will be generated	
	dest_md     string // path where the md files will be generated
	title       string
	pages       map[string]&Page // links to the object in tree
	files       map[string]&File
	images      map[string]&File
	path        Path
	errors      []BookError
	state       BookState
	doc_summary &markdowndocs.Doc [str: skip]
}

pub fn (mut book MDBook) error(args BookErrorArgs) {
	book.errors << BookError{
		msg: args.msg
		cat: args.cat
	}
}

[params]
pub struct BookNewArgs {
pub mut:
	name      string [required] // name of the book
	path      string // path exists
	dest      string // path where book will be generated
	dest_md   string // path where the md files will be generated
	git_url   string
	git_reset bool
	git_root  string // in case we want to checkout code on other location
	git_pull  bool
}

// get a new book
//
// name      string [required] // name of the book
// path      string // path exists
// dest      string // path where book will be generated
// dest_md   string // path where the md files will be generated
// git_url   string
// git_reset bool
// git_root  string // in case we want to checkout code on other location
// git_pull  bool
//
// if dest not filled in will be /tmp/mdbook_export/$name
// if dest_md not filled in will be /tmp/mdbook/$name
//
pub fn (mut l Tree) book_new(args_ BookNewArgs) !&MDBook {
	mut args := args_
	args.name = texttools.name_fix_no_underscore_no_ext(args.name)
	if args.name == '' {
		return error('Cannot specify new book without specifying a name.')
	}

	if args.dest_md == '' {
		args.dest_md = '/tmp/mdbook/${args.name}'
	}

	if args.dest == '' {
		args.dest = '/tmp/mdbook_export/${args.name}'
	}

	if args.name in l.books {
		return error('Book already exists')
	}

	if args.git_url.len > 0 {
		mut gs := gittools.get(root: args.git_root)!
		mut gr := gs.repo_get_from_url(url: args.git_url, pull: args.git_pull, reset: args.git_reset)!
		args.path = gr.path_content_get()
	}

	if args.path.len < 3 {
		return error('Path cannot be empty.')
	}

	mut p := pathlib.get_file(args.path, false)! // makes sure we have the right path
	if !p.exists() {
		return error('cannot find book on path: ${args.path}')
	}
	p.path_normalize()! // make sure its all lower case and name is proper

	mut book := &MDBook{
		name: args.name
		tree: &l
		path: p
		dest: args.dest
		dest_md: args.dest_md
		doc_summary: &markdowndocs.Doc{}
	}
	book.reset()! // clean the destination
	book.load_summary()!
	book.fix_summary()!
	book.link_pages_files_images()!
	book.errors_report()!

	l.books[args.name] = book

	return book
}

// load the summary
fn (mut book MDBook) load_summary() ! {
	mut path_summary := book.path.sub_get(name: 'summary.md', file_ensure: true, name_fix: true) or {
		return error('Cannot find a summary for ${book.path.path}')
	}
	doc := markdowndocs.new(path: path_summary.path) or {
		return error('cannot book parse summary for ${book.path.path}: ${err}')
	}
	book.doc_summary = &doc
}

// reset all, just to make sure we regenerate fresh
pub fn (mut mdbook MDBook) reset() ! {
	// delete where the mdbook are created
	mut a := pathlib.get(mdbook.dest)
	a.delete()!
	mut b := pathlib.get(mdbook.dest_md)
	b.delete()!
}

// fixes the summary doc for the book
fn (mut book MDBook) fix_summary() ! {
	for y in 0 .. book.doc_summary.items.len {
		if book.doc_summary.items[y] is markdowndocs.Paragraph {
			mut paragraph := book.doc_summary.items[y] as markdowndocs.Paragraph
			for x in 0 .. paragraph.items.len {
				if paragraph.items[x] is markdowndocs.Link {
					mut link := paragraph.items[x] as markdowndocs.Link
					if link.isexternal {
						msge := 'external link not supported yet in summary for:\n ${book}'
						book.error(cat: .unknown, msg: msge)
					} else {
						book.tree.logger.debug('book ${book.name} summary:${link.pathfull()}')
						mut collectionname := link.path.all_before('/')
						if link.path == '' {
							// means collection has not been specified
							return error('collection needs to be specified in summary, is the first part of path e.g. collectionname/...')
						}
						pagename := link.filename
						if book.tree.collection_exists(collectionname) {
							mut collection := book.tree.collection_get(collectionname)!
							dest := '${book.path.path}/${collectionname}'
							/*
							// QUESTION: WHy did we need this in the first place?
							if dest != collection.path.path {
								// QUESTION: WHy did we need this in the first place?
								//collection.path.link(dest, true)!
							}
							*/

							// now we can process the page where the link goes to
							if collection.page_exists(pagename) {
								page := collection.page_get(pagename)!
								newlink := '[${link.description}](${collectionname}/${page.pathrel})'
								book.pages['${collection.name}:${page.name}'] = page
								if newlink != link.content {
									book.tree.logger.debug('change: ${link.content} -> ${newlink}')
									paragraph.content = paragraph.content.replace(link.content,
										newlink)
									link.path = collectionname + '/' +
										page.pathrel.all_before_last('/').trim_right('/')
									link.content = newlink
									paragraph.items[x] = link
								}
							} else {
								book.error(
									cat: .page_not_found
									msg: "Cannot find page:'${pagename}' in collection:'${collectionname}'"
								)
								continue
							}
						} else {
							collectionnames := book.tree.collectionnames().join('\n- ')
							msg := 'Cannot find collection: ${collectionname} \ncollectionnames known::\n\n${collectionnames} '
							book.tree.logger.error(msg)
							book.error(
								cat: .collection_not_found
								msg: msg
							)
							continue
						}
					}
				}
			}
			book.doc_summary.items[y] = paragraph
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
							pageobj := page.collection.page_get(link.filename) or {
								book.error(
									cat: .page_not_found
									msg: 'Cannot find page: ${link.filename} in ${page.name}'
								)
								continue
							}
							book.pages['${pageobj.collection.name}:${pageobj.name}'] = pageobj
						}
						if link.cat == .file {
							fileobj := page.collection.file_get(link.filename) or {
								book.error(
									cat: .file_not_found
									msg: 'Cannot find file: ${link.filename} in ${page.name}'
								)
								continue
							}
							book.files['${fileobj.collection.name}:${fileobj.name}'] = fileobj
						}
						if link.cat == .image {
							imageobj := page.collection.image_get(link.filename) or {
								book.error(
									cat: .image_not_found
									msg: 'Cannot find image: ${link.filename} in ${page.name}'
								)
								continue
							}
							book.images['${imageobj.collection.name}:${imageobj.name}'] = imageobj
						}
					}
				}
			}
		}
	}
}

pub fn (mut book MDBook) errors_report() ! {
	// Add errors of the collections to the report
	mut collection_errors := map[string]string{}
	for _, mut page in book.pages {
		if page.collection.errors.len > 0 {
			collection_errors[page.collection.name] = '${page.collection.path.path}/errors.md'
		}
	}

	for _, mut file in book.files {
		if file.collection.errors.len > 0 {
			collection_errors[file.collection.name] = '${file.collection.path.path}/errors.md'
		}
	}

	for _, mut image in book.images {
		if image.collection.errors.len > 0 {
			collection_errors[image.collection.name] = '${image.collection.path.path}/errors.md'
		}
	}
	for collection_name, error_path in collection_errors {
		mut path_error_file := pathlib.get(error_path)
		path_error_file.copy(mut pathlib.get('${book.md_path('').path}/src/errors_${collection_name}.md'))!

		book.error(
			cat: .collection_error
			msg: 'There were one or more errors in collection ${collection_name}, please take a look at [the collection\'s error page](errors_${collection_name}.md)'
		)
	}

	c := $tmpl('template/errors.md')
	mut p2 := pathlib.get('${book.dest_md}/src/errors.md')
	if book.errors.len == 0 {
		p2.delete()!
		return
	}
	p2.write(c)!

	mut paragraph := markdowndocs.Paragraph{}
	paragraph.items << markdowndocs.Text{
		content: '- '
	}
	paragraph.items << markdowndocs.Link{
		cat: .page
		description: 'Errors'
		filename: 'errors.md'
	}
	for collection_name, error_path in collection_errors {
		paragraph.items << markdowndocs.Text{
			content: '\n  - '
		}
		paragraph.items << markdowndocs.Link{
			cat: .page
			description: 'Errors in collection ${collection_name}'
			filename: 'errors_${collection_name}.md'
		}
	}
	book.doc_summary.items << paragraph
}

// return path where the book will be created (exported and built from)
fn (book MDBook) md_path(path string) Path {
	return pathlib.get(book.dest_md + '/${path}')
}

// return path where the book will be created (exported and built from)
fn (book MDBook) html_path(path string) Path {
	return pathlib.get(book.dest + '/${path}')
}

// export an mdbook to its html representation and open the html
pub fn (mut book MDBook) read() ! {
	book.export()!
	osal.exec(cmd: 'open ${book.html_path('').path}/index.html', shell: true)!
}

// export an mdbook to its html representation
pub fn (mut book MDBook) export() ! {
	book.template_install()! // make sure all required template files are in collection
	md_path := book.md_path('').path + '/src'
	html_path := book.html_path('').path
	for _, mut page in book.pages {
		dest := '${md_path}/${page.collection.name}/${page.pathrel}'
		book.tree.logger.info('- export: ${dest}')
		page.save(dest: dest)!
	}

	for _, mut file in book.files {
		dest := '${md_path}/${file.collection.name}/${file.pathrel}'
		book.tree.logger.info('- export: ${dest}')
		5
	}

	for _, mut image in book.images {
		dest := '${md_path}/${image.collection.name}/${image.pathrel}'
		book.tree.logger.info('- export: ${dest}')
		image.copy(dest)!
	}

	mut pathsummary := pathlib.get('${md_path}/SUMMARY.md')
	// write summary
	pathsummary.write(book.doc_summary.wiki())!

	// lets now build
	osal.exec(cmd: 'mdbook build ${book.md_path('').path} --dest-dir ${html_path}', retry: 0)!

	book.tree.logger.info('MDBook has been generated under ${md_path}')
	book.tree.logger.info('HTML pages are found under ${html_path}')
}

fn (mut book MDBook) template_write(path string, content string) ! {
	mut dest_path := book.md_path(path)
	dest_path.write(content)!
}

fn (mut book MDBook) template_install() ! {
	if book.title == '' {
		book.title = book.name
	}

	// get embedded files to the mdbook dir
	for item in book.tree.embedded_files {
		md_path := item.path.all_after_first('/')
		book.template_write(md_path, item.to_string())!
	}
	c := $tmpl('template/book.toml')
	book.template_write('book.toml', c)!
}
