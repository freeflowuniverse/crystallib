module knowledgetree

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.tools.imagemagick
import freeflowuniverse.crystallib.data.markdowndocs
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal
import log
import os

[params]
pub struct BookGenerateArgs {
pub mut:
	name      string [required] // name of the book
	path      string // path exists
	dest      string // path where book will be generated
	dest_md   string // path where the md files will be generated
	tree      Tree
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
pub fn book_generate(args_ BookGenerateArgs) !&MDBook {
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

	if args.git_url.len > 0 {
		mut gs := gittools.get(name: args.git_root) or { gittools.new()! }
		mut locator := gs.locator_new(args.git_url)!
		mut gr := gs.repo_get(locator: locator)!
		args.path = locator.path_on_fs()!.path
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
		tree: &args.tree
		path: p
		dest: args.dest
		dest_md: args.dest_md
		doc_summary: &markdowndocs.Doc{}
	}
	book.reset()! // clean the destination
	book.load_summary()!
	book.link_pages_files_images()!
	book.fix_summary()!
	book.errors_report()!
	book.export()!
	pages_str := book.pages.values().map('\n${it.name}\npages_included:${it.pages_linked.map(it.name)}')

	return book
}
