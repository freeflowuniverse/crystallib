module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree
// import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.develop.gittools
import os
import freeflowuniverse.crystallib.core.texttools

@[heap]
pub struct ZolaSite {
pub mut:
	name         string
	url          string       @[required] // base url of site
	title        string
	description  string
	path_build   pathlib.Path
	path_publish pathlib.Path
	zola         &Zola        @[skip; str: skip]
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
	mut session := site.zola.session()!
	mut gs := session.context.gitstructure()!
	mut mypath := gs.code_get(args)!
	if os.exists('${mypath}/content') {
		mypath = '${mypath}/content'
	}
	os.cp_all('${mypath}', '${site.path_build.path}/content', true)!
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
	mut tree := doctree.tree_get(name: 'ws_${site.name}')!

	tree.scan(git_url: args.url, git_reset: args.reset, git_pull: args.pull, load: args.reload)!
	tree.export(dest: '${site.path_build.path}/doctree', reset: true)!
}
