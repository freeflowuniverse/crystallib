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
	tree  	 &Tree            [str: skip]
	name     string
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
pub mut:
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

	mut b := &MDBook{
		name: args.name
		tree: &l
		path: p
		dest: args.dest
	}

	b.process_summary()!

	l.books[args.name] = b

	return b
	
}

//process the summary
fn (mut book MDBook) process_summary()! {
	mut p := pathlib.get_file('${book.path.path}/summary.md', false)!
	if !p.exists() {
		p = pathlib.get_file('${book.path.path}/SUMMARY.md', false)!
		if !p.exists() {
			return error('cannot find summary.md for book under ${book.path.path}/')
		}
	}
	doc := markdowndocs.new(path: p.path) or {
		return error('cannot book parse ${book.path.path}: ${err}')
	}

	book.doc_summary = &doc

	book.fix()!
}


// fix summary (this means summary will put the )
// walk over pages find broken links
// report on the errors
pub fn (mut book MDBook) fix() ! {
	book.fix_summary()!
	book.link_pages_files_images()!
	book.errors_report()!
}


pub fn (mut mdbook MDBook) init() ! {
	// QUESTION: what should init do?
	mdbook.process_summary()!
}


// reset all, just to make sure we regenerate fresh
pub fn (mut mdbook MDBook) reset() ! {
	// delete where the mdbook are created
	for item in ['mdbook', 'html'] {
		mut a := pathlib.get(mdbook.dest + '/${item}')
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
							collection.path.link(dest, true)!

							// now we can process the page where the link goes to
							if collection.page_exists(pagename) {
								page := collection.page_get(pagename)!
								newlink := '[${link.description}](${collectionname}/${page.pathrel})'
								book.pages['${collection.name}:${page.name}'] = page
								if newlink != link.content {
									book.tree.logger.debug('change: $link.content -> $newlink')
									paragraph.content = paragraph.content.replace(link.content,
										newlink)
									// TODO: don't think we need this one
									//panic('new page is ${link.content} with ${newlink}')
									//paragraph.doc.save_wiki()!
									//panic('not implemented save wiki')
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
							book.error(
								cat: .collection_not_found
								msg: 'Cannot find collection: ${collectionname} \n\collectionnames known::\n\n${collectionnames} '
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
	dest0 := book.dest
	return pathlib.get('${dest0}/books/${book.name}/${path}')
}

// return path where the book will be created (exported and built from)
fn (book MDBook) html_path(path string) Path {
	dest0 := book.dest
	return pathlib.get('${dest0}/html/${book.name}/${path}')
}

// export an mdbook to its html representation
pub fn (mut book MDBook) export() ! {
	book.template_install()! // make sure all required template files are in collection
	book_path := book.book_path('').path + '/src'
	html_path := book.html_path('').path
	for _, mut page in book.pages {
		dest := '${book_path}/${page.collection.name}/${page.pathrel}'
		book.tree.logger.info('- export: ${dest}')
		page.save(dest: dest)!
	}

	for _, mut file in book.files {
		dest := '${book_path}/${file.collection.name}/${file.pathrel}'
		book.tree.logger.info('- export: ${dest}')
		file.copy(dest)!
	}

	for _, mut image in book.images {
		dest := '${book_path}/${image.collection.name}/${image.pathrel}'
		book.tree.logger.info('- export: ${dest}')
		image.copy(dest)!
	}

	mut pathsummary := pathlib.get('${book_path}/SUMMARY.md')
	// write summary
	pathsummary.write(book.doc_summary.wiki())!

	// lets now build
	osal.exec(cmd: 'mdbook build ${book.book_path('').path} --dest-dir ${html_path}', retry: 0)!

	book.tree.logger.info('MDBook has been generated under ${book_path}')
	book.tree.logger.info('Html pages are found under ${html_path}')
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
	for item in book.tree.embedded_files {
		book_path := item.path.all_after_first('/')
		book.template_write(book_path, item.to_string())!
	}
	c := $tmpl('template/book.toml')
	book.template_write('book.toml', c)!
}
