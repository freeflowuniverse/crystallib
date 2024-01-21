// module doctree

// import freeflowuniverse.crystallib.osal.gittools
// import freeflowuniverse.crystallib.tools.imagemagick
// import freeflowuniverse.crystallib.data.markdownparser
// import freeflowuniverse.crystallib.data.markdownparser.elements
// import freeflowuniverse.crystallib.core.pathlib { Path }
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.osal.mdbook
// import log
// import os

// __global (
// 	logger = log.Log{
// 		level: .debug
// 	}
// )

// enum BookState {
// 	init
// 	initdone
// 	scanned // needed?
// 	fixed
// 	ok
// }

// pub enum BookErrorCat {
// 	unknown
// 	file_not_found
// 	image_not_found
// 	page_not_found
// 	playbook_not_found
// 	playbook_error
// 	sidebar
// }

// @[heap]
// struct BookErrorArgs {
// 	msg string
// 	cat BookErrorCat
// }

// @[heap]
// struct BookError {
// pub mut:
// 	msg string
// 	cat BookErrorCat
// }

// @[heap]
// pub struct MDBook {
// pub mut:
// 	tree        &Tree            @[str: skip]
// 	name        string
// 	dest        string // path where book will be generated	
// 	dest_md     string // path where the md files will be generated
// 	title       string
// 	pages       map[string]Page // needs to be a new copy
// 	files       map[string]&File
// 	images      map[string]&File
// 	path        Path
// 	errors      []BookError
// 	state       BookState
// 	doc_summary &elements.Doc    @[str: skip]
// }

// pub fn (mut book MDBook) error(args BookErrorArgs) {
// 	book.errors << BookError{
// 		msg: args.msg
// 		cat: args.cat
// 	}
// }

// @[params]
// pub struct BookNewArgs {
// pub mut:
// 	name      string @[required] // name of the book
// 	path      string // path exists
// 	dest      string // path where book will be generated
// 	dest_md   string // path where the md files will be generated
// 	tree_name string
// 	git_url   string
// 	git_reset bool
// 	git_root  string // in case we want to checkout code on other location
// 	git_pull  bool
// }

// // get a new book
// //
// // name      string @[required] // name of the book
// // path      string // path exists
// // dest      string // path where book will be generated
// // dest_md   string // path where the md files will be generated
// // git_url   string
// // git_reset bool
// // git_root  string // in case we want to checkout code on other location
// // git_pull  bool
// //
// // if dest not filled in will be /tmp/mdbook_export/$name
// // if dest_md not filled in will be /tmp/mdbook/$name
// //
// pub fn book_create(args_ BookNewArgs) !&MDBook {
// 	mut args := args_
// 	args.name = texttools.name_fix_no_underscore_no_ext(args.name)
// 	if args.name == '' {
// 		return error('Cannot specify new book without specifying a name.')
// 	}

// 	if args.dest_md == '' {
// 		args.dest_md = '/tmp/mdbook/${args.name}'
// 	}

// 	if args.dest == '' {
// 		args.dest = '/tmp/mdbook_export/${args.name}'
// 	}

// 	if args.git_url.len > 0 {
// 		mut gs := gittools.get(name: 'tree') or {
// 			return error('cant find gitstructure with name tree.')
// 		}
// 		locator := gs.locator_new(args.git_url)!
// 		mut gr := gs.repo_get(locator: locator)!
// 		args.path = gr.path.path
// 	}

// 	if args.path.len < 3 {
// 		return error('Path cannot be empty.')
// 	}

// 	mut p := pathlib.get_file(path: args.path)! // makes sure we have the right path
// 	if !p.exists() {
// 		return error('cannot find book on path: ${args.path}')
// 	}
// 	p.path_normalize()! // make sure its all lower case and name is proper

// 	mut tree := knowledgetrees[args.tree_name] // reference to clone of seed tree
// 	rlock knowledgetrees {
// 		tree = knowledgetrees[args.tree_name]
// 	}

// 	mut book := &MDBook{
// 		name: args.name
// 		tree: &tree
// 		path: p
// 		dest: args.dest
// 		dest_md: args.dest_md
// 		doc_summary: &elements.Doc{}
// 	}
// 	book.reset()! // clean the destination
// 	book.load_summary()!
// 	book.link_pages_files_images()!
// 	book.fix_summary()!
// 	book.process()!
// 	book.errors_report()!
// 	book.export()!

// 	return book
// }

// // load the summary
// fn (mut book MDBook) load_summary() ! {
// 	// QUESTION: do we assume that passed path is the path of summary file?
// 	// mut path_summary := book.path.sub_get(name: 'summary.md', file_ensure: true, name_fix: true) or {
// 	// 	return error('Cannot find a summary for ${book.path.path}')
// 	// }
// 	doc := markdownparser.new(path: book.path.path) or {
// 		return error('cannot book parse summary for ${book.path.path}: ${err}')
// 	}
// 	book.doc_summary = &doc
// }

// // reset all, just to make sure we regenerate fresh
// fn (mut book MDBook) reset() ! {
// 	// delete where the mdbook are created
// 	mut a := pathlib.get(book.dest)
// 	a.delete()!
// 	mut b := pathlib.get(book.dest_md)
// 	b.delete()!
// }

// // fixes the summary doc for the book
// fn (mut book MDBook) fix_summary() ! {
// 	// add linked pages to summary if they dont exist in summary

// 	for y in 0 .. book.doc_summary.children.len {
// 		mut paragraph := book.doc_summary.children[y]
// 		if mut paragraph is elements.Paragraph {
// 			for x in 0 .. paragraph.children.len {
// 				mut link := paragraph.children[x]
// 				if mut link is elements.Link {
// 					if link.isexternal {
// 						msge := 'external link not supported yet in summary for:\n ${book}'
// 						book.error(cat: .unknown, msg: msge)
// 					} else {
// 						book.tree.logger.debug('book ${book.name} summary:${link.pathfull()}')
// 						mut playbookname := link.url.all_before(':')
// 						if playbookname == '' {
// 							// means playbook has not been specified
// 							return error('playbook needs to be specified in summary, is the first part of path e.g. playbookname/...')
// 						}
// 						pagename := link.filename
// 						if book.tree.playbook_exists(playbookname) {
// 							// clone playbook so that changes don't mutate playbook in doctree
// 							playbook_ := book.tree.playbook_get(playbookname)!
// 							mut playbook := Collection{
// 								...playbook_
// 							}

// 							// now we can process the page where the link goes to
// 							if playbook.page_exists(pagename) {
// 								page := playbook.page_get(pagename)!
// 								book.tree.logger.debug('found page: ${page.path.path}')
// 								newlink := '[${link.description}](${playbookname}/${page.pathrel})'
// 								book.pages['${playbook.name}:${page.name}'] = page
// 								if newlink != link.content {
// 									book.tree.logger.debug('change: ${link.content} -> ${newlink}')
// 									paragraph.content = paragraph.content.replace(link.content,
// 										newlink)
// 									newpath := playbookname + '/' + page.pathrel
// 									link.path = newpath.all_before_last('/').trim_right('/')
// 									link.url = '${link.path}/${link.filename}'
// 									link.content = newlink
// 									link.cat = elements.LinkType.file
// 								}
// 							} else {
// 								book.error(
// 									cat: .page_not_found
// 									msg: "Cannot find page:'${pagename}' in playbook:'${playbookname}'"
// 								)
// 								continue
// 							}
// 						} else {
// 							playbooknames := book.tree.playbooknames().join('\n- ')
// 							msg := 'Cannot find playbook: ${playbookname} \nplaybooknames known::\n\n${playbooknames} '
// 							book.tree.logger.error(msg)
// 							book.error(
// 								cat: .playbook_not_found
// 								msg: msg
// 							)
// 							continue
// 						}
// 					}
// 				}
// 			}
// 		}
// 	}
// 	book.tree.logger.debug('finished fixing summary')
// }

// // add_page_to_summary adds pages that have been linked to summary
// fn (mut book MDBook) add_missing_pages_to_summary() ! {
// 	mut path_summary := pathlib.get('${book.dest_md}/src/SUMMARY.md')
// 	summary_content := os.read_file(path_summary.path)!
// 	mut dest_md_path := pathlib.get('${book.dest_md}/src')
// 	mut fl := dest_md_path.list()!

// 	mut files := []Path{}
// 	for mut path in fl.paths {
// 		if path.is_file() {
// 			files << path
// 		}
// 	}

// 	mut missing_links := []string{}
// 	for mut file in files.filter(!it.path.ends_with('SUMMARY.md')) {
// 		rel_path := file.path.trim_string_left('${book.dest_md}/src/')

// 		if !summary_content.contains(file.path.trim_string_left('${book.dest_md}/src/')) {
// 			missing_links << '\t- [${file.name_fix_no_ext()}](${rel_path})'
// 		}
// 	}

// 	if missing_links.len > 0 {
// 		missing_links_str := '- [Missing links]()\n${missing_links.join('\n')}'
// 		os.write_file(path_summary.path, '${summary_content}.${missing_links_str}')!
// 	}
// }

// // all images, files and pages found need to be linked to the book
// // find which files,pages, images are not found
// fn (mut book MDBook) link_pages_files_images() ! {
// 	logger.info('Linking pages, files, and images in MDBook: ${book.name}')
// 	for _, page in book.pages {
// 		logger.info('Linking pages, files, and images in MDBook: ${book.name} page: ${page.name}')
// 		doc := page.doc or { return }
// 		for paragraph in doc.children.filter(it is elements.Paragraph) {
// 			if paragraph is elements.Paragraph {
// 				for item in paragraph.children {
// 					if item is elements.Link {
// 						link := item

// 						if link.cat == .page {
// 							logger.info('Linking page ${link.filename} from ${link.path} into ${page.name}')
// 							playbook := book.tree.playbook_get(page.playbook_name) or {
// 								logger.error('Could not link page ')
// 								panic('couldnt find book playbook')
// 							}
// 							pageobj := playbook.page_get(link.filename) or {
// 								book.error(
// 									cat: .page_not_found
// 									msg: '${page.path.path}: Cannot find page ${link.filename} in ${page.playbook_name}'
// 								)
// 								continue
// 							}
// 							book.pages['${pageobj.playbook_name}:${pageobj.name}'] = pageobj
// 						} else if link.cat == .file {
// 							playbook := book.tree.playbook_get(page.playbook_name) or {
// 								panic('couldnt find book playbook')
// 							}
// 							playbook.file_get(link.filename) or {
// 								book.error(
// 									cat: .file_not_found
// 									msg: '${page.path.path}: Cannot find file ${link.filename} in ${page.playbook_name}'
// 								)
// 								continue
// 							}
// 							// book.files['${fileobj.playbook.name}:${fileobj.name}'] = fileobj
// 						} else if link.cat == .image {
// 							playbook := book.tree.playbook_get(page.playbook_name) or {
// 								panic('couldnt find book playbook')
// 							}
// 							playbook.image_get(link.filename) or {
// 								book.error(
// 									cat: .image_not_found
// 									msg: '${page.path.path}: Cannot find image ${link.filename} in ${page.playbook_name}'
// 								)
// 								continue
// 							}
// 							// book.images['${imageobj.playbook.name}:${imageobj.name}'] = imageobj
// 						}
// 					}
// 				}
// 			}
// 		}
// 	}
// 	logger.info('finished linking pages files images')
// }

// fn (mut book MDBook) errors_report() ! {
// 	// Look for errors in linked playbooks
// 	mut playbook_errors := map[string]&Collection{}
// 	for _, mut page in book.pages {
// 		playbook := book.tree.playbook_get(page.playbook_name) or {
// 			panic('couldnt find book playbook')
// 		}
// 		if playbook.errors.len > 0 {
// 			playbook_errors[page.playbook_name] = &playbook
// 		}
// 	}

// 	for _, mut file in book.files {
// 		if file.playbook.errors.len > 0 {
// 			playbook_errors[file.playbook.name] = file.playbook
// 		}
// 	}

// 	for _, mut image in book.images {
// 		if image.playbook.errors.len > 0 {
// 			playbook_errors[image.playbook.name] = image.playbook
// 		}
// 	}
// 	// Export the errors of the playbooks that contain errors
// 	for playbook_name, playbook in playbook_errors {
// 		playbook.errors_report('${book.md_path('').path}/src/errors_${playbook_name}.md') or {
// 			return error('failed to report errors for playbook ${playbook_name}')
// 		}
// 		book.error(
// 			cat: .playbook_error
// 			msg: 'There were one or more errors in playbook ${playbook_name}, please take a look at [the playbook\'s error page](errors_${playbook_name}.md)'
// 		)
// 	}
// 	// Lets link the errors in the errors.md file
// 	c := $tmpl('../../../osal/mdbook/template/errors.md')
// 	mut p2 := pathlib.get('${book.dest_md}/src/errors.md')
// 	if book.errors.len == 0 {
// 		p2.delete()!
// 		return
// 	}
// 	p2.write(c)!

// 	mut paragraph := elements.Paragraph{}
// 	paragraph.children << elements.Text{
// 		content: '- '
// 	}
// 	paragraph.children << elements.Link{
// 		cat: .page
// 		description: 'Errors'
// 		filename: 'errors.md'
// 	}
// 	for playbook_name, _ in playbook_errors {
// 		paragraph.children << elements.Text{
// 			content: '\n  - '
// 		}
// 		paragraph.children << elements.Link{
// 			cat: .page
// 			description: 'Errors in playbook ${playbook_name}'
// 			filename: 'errors_${playbook_name}.md'
// 		}
// 	}
// 	book.doc_summary.children << paragraph
// }

// // return path where the book will be created (exported and built from)
// fn (book MDBook) md_path(path string) Path {
// 	return pathlib.get(book.dest_md + '/${path}')
// }

// // return path where the book will be created (exported and built from)
// fn (book MDBook) html_path(path string) Path {
// 	return pathlib.get(book.dest + '/${path}')
// }

// fn (mut book MDBook) export_linked_pages(md_path string, mut linked_pages []&Page) ! {
// 	for mut page_linked in linked_pages {
// 		if page_linked.pages_linked.len > 0 {
// 			book.export_linked_pages(md_path, mut page_linked.pages_linked)!
// 		}
// 		dest := '${md_path.trim_right('/')}/${page_linked.playbook_name}/${page_linked.pathrel}'
// 		book.tree.logger.info('export: ${dest}')
// 		page_linked.save(dest: dest)!
// 	}
// }

// // process processes the pages in an mdbook
// pub fn (mut book MDBook) process() ! {
// 	book.process_includes() or { return error('Failed to process includes, ${err}') }
// 	logger.info('Processing pages in book')
// 	for _, mut page in book.pages {
// 		page.process()!
// 	}
// }

// // export an mdbook to its html representation
// pub fn (mut book MDBook) export() ! {
// 	logger.info('Exporting MDBook: ${book.name}')

// 	embedded_files := mdbook.get_embedded_files()
// 	mut params := mdbook.Params{
// 		title: book.title
// 		embedded_files: embedded_files
// 		path_build: pathlib.get_dir(path: book.md_path('').path, create: true)!
// 		path_publish: pathlib.get_dir(path: book.html_path('').path, create: true)!
// 	}
// 	mdbook.template_install(mut params)!

// 	md_path := book.md_path('').path + 'src'
// 	html_path := book.html_path('').path
// 	logger.info('Exporting pages in MDBook: ${book.name}')

// 	for _, mut page in book.pages {
// 		if page.pages_linked.len > 0 {
// 			book.export_linked_pages(md_path, mut page.pages_linked)!
// 		}

// 		dest := '${md_path}/${page.playbook_name}/${page.pathrel}'
// 		logger.info('Exporting page: ${page.name}')
// 		page.export(dest: dest)!
// 		logger.info('Exported page: ${page.name}')
// 	}

// 	logger.info('Exporting files in MDBook: ${book.name}')
// 	for _, mut file in book.files {
// 		dest := '${md_path}/${file.playbook.name}/${file.pathrel}'
// 		logger.info('Exporting file: ${dest}')
// 	}

// 	for _, mut image in book.images {
// 		mut dest := '${md_path}/${image.playbook.name}/${image.pathrel}'
// 		book.tree.logger.info('export image: ${dest}')
// 		image.copy(dest)!

// 		mut path_dest := pathlib.get(dest)
// 		if imagemagick.installed() {
// 			book.tree.logger.debug('downsizing image ${path_dest.path}')
// 			mut image_to_downsize := imagemagick.image_new(mut path_dest) or {
// 				panic('imagemagick: cannot create new image from ${path_dest.path}: ${err}')
// 			}
// 			image_to_downsize.downsize(backup: false)!
// 			if image_to_downsize.path.path != path_dest.path {
// 				os.mv(image_to_downsize.path.path, path_dest.path)!
// 			}
// 		}
// 	}

// 	mut pathsummary := pathlib.get('${md_path}/SUMMARY.md')
// 	// write summary
// 	pathsummary.write(book.doc_summary.markdown())!
// 	book.add_missing_pages_to_summary()!

// 	// lets now build
// 	osal.exec(cmd: 'mdbook build ${book.md_path('').path} --dest-dir ${html_path}', retry: 0) or {
// 		return error('failed to build mdbook: ${err}')
// 	}
// 	for item in book.tree.embedded_files {
// 		if item.path.ends_with('.css') {
// 			logger.info('Writing css files into MDBook')
// 			css_name := item.path.all_after_last('/')
// 			osal.file_write('${html_path.trim_right('/')}/css/${css_name}', item.to_string())!
// 		}
// 	}

// 	book.tree.logger.info('MDBook has been generated under ${md_path}')
// 	book.tree.logger.info('HTML pages are found under ${html_path}')
// }

// fn (mut book MDBook) template_write(path string, content string) ! {
// 	mut dest_path := book.md_path(path)
// 	dest_path.write(content)!
// }

// fn (mut book MDBook) template_install() ! {
// 	if book.title == '' {
// 		book.title = book.name
// 	}

// 	template_files := {
// 		'print.css':       $embed_file('../../osal/mdbook/template/css/print.css')
// 		'variable.css':    $embed_file('../../osal/mdbook/template/css/variables.css')
// 		'general.css':     $embed_file('../../osal/mdbook/template/css/general.css')
// 		'mermaid-init.js': $embed_file('../../osal/mdbook/template/mermaid-init.js')
// 		'echarts.min.js':  $embed_file('../../osal/mdbook/template/echarts.min.js')
// 		'mermaid.min.js':  $embed_file('../../osal/mdbook/template/mermaid.min.js')
// 	}

// 	for k, v in template_files {
// 		book.template_write(k, v.to_string())!
// 	}

// 	// get embedded files to the mdbook dir
// 	for item in book.tree.embedded_files {
// 		md_path := item.path.all_after_first('/')
// 		book.template_write(md_path, item.to_string())!
// 	}

// 	js_files_path := '${os.home_dir()}/.vmodules/freeflowuniverse/crystallib/osal/mdbook/template'
// 	c := $tmpl('../../../osal/mdbook/template/book.toml')
// 	book.template_write('book.toml', c)!
// }
