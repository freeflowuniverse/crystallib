module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.data.markdownparser.elements
import os
import freeflowuniverse.crystallib.core.texttools

@[heap]
pub struct ZolaSite {
pub mut:
	name         string
	url          string             @[required] // base url of site
	title        string
	description  string
	path_build   pathlib.Path
	path_publish pathlib.Path
	zola         &Zola              @[skip; str: skip]
	tree         doctree.Tree       @[skip; str: skip]
	pages        []ZolaPage
	header       ?Header
	footer       ?Footer
	blog         Blog
	people       ?People
	news         ?News
<<<<<<< HEAD
	sections     map[string]Section
=======
	sections     []Section
}

pub struct Blog {
pub mut:
	posts map[string]elements.Doc
>>>>>>> c09c2ea (zola fixes)
}

@[params]
pub struct ZolaSiteArgs {
pub mut:
	name         string @[required]
	title        string
	description  string
	path_publish string // optional
	url          string = 'http://localhost:9998/' // base url of site
}

pub fn (mut self Zola) new(args_ ZolaSiteArgs) !&ZolaSite {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut site := ZolaSite{
		name: args.name
		title: args.title
		description: args.description
		url: args.url
		zola: &self
		tree: doctree.new(name: 'ws_${args.name}')!
	}

	self.sites[site.name] = &site

	site.path_build = pathlib.get_dir(
		path: '${self.path_build}/${args.name}'
		create: true
	)!
	if args.path_publish == '' {
		args.path_publish = '${self.path_publish}/${args.name}'
	}
	site.path_publish = pathlib.get_dir(
		path: args.path_publish
		create: true
	)!
	// make sure we have clean env
	for i in ['css', 'static', 'templates', 'content'] {
		if os.exists('${site.path_build.path}/${i}') {
			os.rmdir_all('${site.path_build.path}/${i}')!
		}
	}
	if os.exists('${site.path_build.path}/config.toml') {
		os.rm('${site.path_build.path}/config.toml')!
	}
	site.template_install()!
	return &site
}

pub fn (mut self Zola) get(name_ string) !&ZolaSite {
	name := texttools.name_fix(name_)
	return self.sites[name] or { error('cannot find zolasite with name: ${name}') }
}

// add template
//```args for getting the template
// path   string
// url    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
//```
pub fn (mut site ZolaSite) template_add(args gittools.GSCodeGetFromUrlArgs) ! {
	mut session := site.zola.session()!
	mut gs := session.context.gitstructure()!
	mypath := gs.code_get(args)!
	for i in ['css', 'static', 'templates'] {
		os.cp_all('${mypath}/${i}', '${site.path_build.path}/${i}', true)!
	}
}

// add content from website, can be more than 1, will sync but not overwrite to the destination website
//```args for getting the template
// path   string
// url    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
//```
pub fn (mut site ZolaSite) content_add(args gittools.GSCodeGetFromUrlArgs) ! {
	site.tree.scan(git_url: args.url, git_reset: args.reset, git_pull: args.pull, load: true)!
	mut session := site.zola.session()!
	mut gs := session.context.gitstructure()!
	mut mypath := gs.code_get(args)!
	if os.exists('${mypath}/content') {
		mypath = '${mypath}/content'
	}
	content_dest := '${site.path_build.path}/content'
	mut content_dir := pathlib.get_dir(path: content_dest)!
	os.cp_all('${mypath}', content_dest, true)!
<<<<<<< HEAD
=======

	md_list := content_dir.list(
		recursive: true
		regex: [r'.*\.md$']
	)!
	for mdfile in md_list.paths {
		_ = markdownparser.new(path: mdfile.path)!
		// for include in doc.children.filter(it is elements.Include) {
		// 	println('incl: ${include}')
		// }
		// pointers := doc.action_pointers()
	}
}

pub struct BlogAddArgs {
	name       string
	collection string @[required]
	file       string @[required]
	image      string
}

pub fn (mut site ZolaSite) blog_add(args BlogAddArgs) ! {
	site.tree.process_includes()!
	_ = site.tree.collection_get(args.collection) or {
		println(err)
		return err
	}
	mut page := site.tree.page_get('${args.collection}:${args.file}') or {
		println(err)
		return err
	}
	mut image := site.tree.image_get('${args.collection}:${args.image}') or {
		println(err)
		return err
	}

	mut blog_index := pathlib.get_file(
		path: '${site.path_build.path}/content/blog/_index.md'
	)!
	if !blog_index.exists() {
		blog_index.write('---
title: "Blog"
paginate_by: 9

# paginate_reversed: false

sort_by: "date"
insert_anchor_links: "left"
#base_url: "posts"
#first: "first"
#last: "last"
template: "layouts/blog.html"
page_template: "blogPage.html"
#transparent: true
generate_feed: true
extra:
  imgPath: images/threefold_img2.png
---
')!
	}

	blog_dir := pathlib.get_dir(
		path: '${site.path_build.path}/content/blog'
		create: true
	)!
	fixed_name := '${texttools.name_fix(args.name)}'
	post_dir := pathlib.get_dir(
		path: '${blog_dir.path}/${fixed_name}'
		create: true
	)!
	page.export(dest: '${post_dir.path}/index.md')!
	image.copy('${post_dir.path}/${image.file_name()}')!

	site.blog.posts[args.name] = page.doc()!
>>>>>>> c09c2ea (zola fixes)
}

// add collections from doctree
//```args for getting the template
// path   string
// url    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
//```
pub fn (mut site ZolaSite) doctree_add(args gittools.GSCodeGetFromUrlArgs) ! {
	site.tree.scan(git_url: args.url, git_reset: args.reset, git_pull: args.pull, load: args.reload)!
	doctree_dest := '${site.path_build.path}/doctree'
	mut doctree_dir := pathlib.get_dir(path: doctree_dest)!
	_ = doctree_dir.list(
		recursive: true
		regex: [r'.*\.md$']
		include_links: true
	)!
	site.tree.process_includes()!
}

pub fn (mut site ZolaSite) add_section(section_ Section) ! {
	section := Section{
		...section_
		name: texttools.name_fix(section_.name)
	}

	if section.name in site.sections {
		return error('Section with name `${section.name}` already exists.')
	}

	//  = 'section.html'
	site.sections[section.name] = section
}
