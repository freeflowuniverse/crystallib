module mdbook

import freeflowuniverse.crystallib.osal
import os
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.redisclient

@[heap]
pub struct MDBook {
pub mut:
	name         string
	books        &MDBooks[Config]          @[skip; str: skip]
	path_build   pathlib.Path
	path_publish pathlib.Path
	args         MDBookArgs
	errors       []doctree.CollectionError
}

@[params]
pub struct MDBookArgs {
pub mut:
	name         string @[required]
	title        string
	summary_url  string // url of the summary.md file
	summary_path string // can also give the path to the summary file (can be the dir or the summary itself)
	doctree_url  string
	doctree_path string
	publish_path string
	build_path   string
}

pub fn (mut books MDBooks[Config]) generate(args_ MDBookArgs) !&MDBook {
	console.print_header(' mdbook: ${args_.name}')

	mut cfg := books.config()!

	mut args := args_
	if args.title == '' {
		args.title = args.name
	}
	if args.build_path.len == 0 {
		args.build_path = '${cfg.path_build}/${args.name}'
	}
	if args.publish_path.len == 0 {
		args.publish_path = '${cfg.path_publish}/${args.name}'
	}

	mut r := redisclient.core_get()!
	r.set('mdbook:${args.name}:build', args.build_path)!
	r.set('mdbook:${args.name}:publish', args.publish_path)!
	r.expire('mdbook:${args.name}:build', 3600 * 12)! // expire after 12h
	r.expire('mdbook:${args.name}:publish', 3600 * 12)!

	mut context := books.context()!
	mut gs := context.gitstructure()!

	if args.summary_url.len > 0 {
		mut locator1 := gs.locator_new(args.summary_url)!
		gs.repo_get(locator: locator1, reset: false, pull: false)!
		mut path_summary := locator1.path_on_fs()!
		if !path_summary.exists() {
			return error('cannot find path for summary: ${path_summary.path}')
		}
		if path_summary.is_file() {
			args.summary_path = path_summary.path
		} else if path_summary.is_dir() {
			path_summary_path := path_summary.file_get_ignorecase('summary.md')!
			args.summary_path = path_summary_path.path
		} else {
			return error('summary from git needs to be dir or file')
		}
	}

	if args.doctree_url.len > 0 {
		mut locator2 := gs.locator_new(args.doctree_url)!
		gs.repo_get(locator: locator2, reset: false, pull: false)!
		mut path_doctree := locator2.path_on_fs()!
		if !path_doctree.exists() {
			return error('cannot find path for doctree: ${path_doctree.path}')
		}
		if path_doctree.is_dir() {
			args.doctree_path = path_doctree.path
		} else {
			return error('doctree from git needs to be dir. ${path_doctree.path}')
		}
	}

	mut book := MDBook{
		args: args
		path_build: pathlib.get_dir(path: args.build_path, create: true)!
		path_publish: pathlib.get_dir(path: args.publish_path, create: true)!
		books: &books
	}

	mut summary := book.summary()!

	// create the additional collection (is a system collection)
	addpath := '${book.path_build.path}/src/additional'
	mut a := pathlib.get_file(path: '${addpath}/additional.md', create: true)!
	mut b := pathlib.get_file(path: '${addpath}/errors.md', create: true)!
	mut c := pathlib.get_file(path: '${addpath}/pages.md', create: true)!

	a.write('
# Additional pages

A normal user can ignore these pages, they are for the authors to see e.g. errors

	')!

	b.write('
# Errors

Be the mother for our errors.

	')!
	c.write('
# Additional pages

A normal user can ignore these pages, they are just to get links to work.

	')!

	for collectionname in summary.collections {
		collection_dir_str := '${args.doctree_path}/src/${collectionname}'.replace('~',
			os.home_dir())
		if !os.exists(collection_dir_str) {
			book.error(
				msg: "Could not find collection: '${collection_dir_str}' "
			)
			continue
		}

		mut collection_dir_path := pathlib.get_dir(path: collection_dir_str, create: false) or {
			panic('bug')
		} // should always work because done in summary
		// check if there are errors, if yes add to summary
		if collection_dir_path.file_exists('errors.md') {
			summary.add_error_page(collectionname, 'errors.md')
		}
		// // now link the collection into the build dir
		collection_dirbuild_str := '${book.path_build.path}/src/${collectionname}'.replace('~',
			os.home_dir())
		if !pathlib.path_equal(collection_dirbuild_str, collection_dir_path.path) {
			collection_dir_path.link(collection_dirbuild_str, true)!
		}
		if collection_dir_path.file_exists('.linkedpages'){
			mut lpages:=collection_dir_path.file_get('.linkedpages')!
			lpagescontent:=lpages.read()!
			for lpagestr in lpagescontent.split_into_lines().filter(it.trim_space()!=""){
				console.print_green("find linked page: ${lpagestr}")
				//format $collection:$pagename.md
				splitted:=lpagestr.split(":")
				assert splitted.len==2
				summary.add_page_additional(collectionname,splitted[1])
			}
		}

	}

	if book.errors.len > 0 {
		book.errors_report()!

		summary.errors << SummaryItem{
			level: 2
			description: 'errors mdbook'
			pagename: 'errors_mdbook.md'
			collection: 'additional'
		}
	}

	// println(summary)

	path_summary_str := '${book.path_build.path}/src/SUMMARY.md'
	mut path_summary := pathlib.get_file(path: path_summary_str, create: true)!
	path_summary.write(summary.str())!

	book.template_install()!

	book.generate()!

	console.print_header(' mdbook prepared: ${book.path_build.path}')

	return &book
}

// write errors.md in the collection, this allows us to see what the errors are
fn (book MDBook) errors_report() ! {
	errors_path_str := '${book.path_build.path}/src/additional/errors_mdbook.md'
	mut dest := pathlib.get_file(path: errors_path_str, create: true)!
	if book.errors.len == 0 {
		dest.delete()!
		return
	}
	c := $tmpl('template/errors.md')
	dest.write(c)!
}

@[params]
pub struct ErrorArgs {
pub mut:
	path string
	msg  string
	cat  doctree.CollectionErrorCat
}

pub fn (mut book MDBook) error(args ErrorArgs) {
	path2 := pathlib.get(args.path)
	e := doctree.CollectionError{
		path: path2
		msg: args.msg
		cat: args.cat
	}
	book.errors << e
	console.print_stderr(args.msg)
}

pub fn (mut book MDBook) open() ! {
	console.print_header('open book: ${book.name}')
	cmd := 'open \'${book.path_build.path}/book/index.html\''
	console.print_debug(cmd)
	// cmd:='bash ${book.path_build.path}/develop.sh'
	osal.exec(cmd: cmd)!
}

pub fn (mut book MDBook) generate() ! {
	console.print_header(' book generate: ${book.name} on ${book.path_build.path}')

	book.summary_image_set()!
	osal.exec(
		cmd: '	
			cd ${book.path_build.path}
			mdbook build --dest-dir ${book.path_publish.path}
			'
		retry: 0
	)!
}

fn (mut book MDBook) template_install() ! {
	// get embedded files to the mdbook dir
	mut l := loader()!
	l.load()!
	for item in l.embedded_files {
		dpath := '${book.path_build.path}/${item.path.all_after_first('/')}'
		console.print_debug(' embed: ${dpath}')
		mut dpatho := pathlib.get_file(path: dpath, create: true)!
		dpatho.write(item.to_string())!
	}

	c := $tmpl('template/book.toml')
	mut tomlfile := book.path_build.file_get_new('book.toml')!
	tomlfile.write(c)!

	c1 := $tmpl('template/build.sh')
	mut file1 := book.path_build.file_get_new('build.sh')!
	file1.write(c1)!
	file1.chmod(0o770)!

	c2 := $tmpl('template/develop.sh')
	mut file2 := book.path_build.file_get_new('develop.sh')!
	file2.write(c2)!
	file2.chmod(0o770)!
}

fn (mut book MDBook) summary_image_set() ! {
	// this is needed to link the first image dir in the summary to the src, otherwise empty home image

	summaryfile := '${book.path_build.path}/src/SUMMARY.md'
	mut p := pathlib.get_file(path: summaryfile)!
	c := p.read()!
	mut first := true
	for line in c.split_into_lines() {
		if !(line.trim_space().starts_with('-')) {
			continue
		}
		if line.contains('](') && first {
			folder_first := line.all_after('](').all_before_last(')')
			folder_first_dir_img := '${book.path_build.path}/src/${folder_first.all_before_last('/')}/img'
			// println(folder_first_dir_img)
			// if true{panic("s")}
			if os.exists(folder_first_dir_img) {
				mut image_dir := pathlib.get_dir(path: folder_first_dir_img)!
				image_dir.link('${book.path_build.path}/src/img', true)!
			}

			first = false
		}
	}
}
