module zola


import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.webcomponents.preprocessor
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.develop.gittools


import os
import freeflowuniverse.crystallib.core.texttools

@[heap]
pub struct ZolaSite {
pub mut:
	name string
	title string
	description string	
	path_build   pathlib.Path
	path_publish pathlib.Path
	zola &Zola  @[skip; str: skip]
}

@[params]
pub struct ZolaSiteArgs {
pub mut:
	name string @[required]
	title string
	description string
	path_publish string //optional
}

pub fn (mut self Zola) new(args_ ZolaSiteArgs)! &ZolaSite {
	mut args:=args_
	args.name = texttools.name_fix(args.name)
	mut site:=ZolaSite{name:args.name,title:args.title,description:args.description, zola:&self }

	self.sites[site.name] = &site

	site.path_build=pathlib.get_dir(
		path: "${self.path_build}/${args.name}"
		create: true
	)!
	if args.path_publish == "" {
		args.path_publish="${self.path_publish}/${args.name}"
	}
	site.path_publish= pathlib.get_dir(
		path: args.path_publish
		create: true
	)!
	return &site
}

pub fn (mut self Zola) get(name_ string)! &ZolaSite {
	name := texttools.name_fix(name_)
	return self.sites[name] or {error("cannot find zolasite with name: ${name}")}
}


//add template 
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
	mut session:=site.zola.session()!
	mut gs:=session.context.gitstructure()!
	mypath:=gs.code_get(args)!
	if true{
		println(mypath)
		panic("sdsdsdsdsdsdsdsdsds")
	}

	site.template_install()!
	if os.exists('${site.path_publish.path}/content') {
		os.rmdir_all('${site.path_publish.path}/content')!
	}
	// os.cp_all(site.path_content.path, '${site.path_build.path}/content', true)!
	// os.cp_all(site.path_content.path, '${site.path_build.path}/static/', true)!

// 	os.cp('${os.dir(@FILE)}/templates/vercel.json', '${site.path_build.path}/vercel.json')!
// 	os.cp_all('${os.dir(@FILE)}/templates/css', '${site.path_build.path}/css', true)!
// 	os.cp_all('${os.dir(@FILE)}/templates/templates', '${site.path_build.path}/templates',
// 		true)!
// 	os.cp_all('${os.dir(@FILE)}/templates/static', '${site.path_build.path}/static', true)!
// }

	preprocessor.preprocess('${site.path_build.path}/content')!
}

//add content from website, can be more than 1, will sync but not overwrite to the destination website 
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
	if true{
		println(args)
		panic("1111")
	}
}


//add collections from doctree
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
	if true{
		println(args)
		panic("11222211")
	}
}


pub fn (mut site ZolaSite) pull() ! {
	console.print_header(' website pull: ${site.name} on ${site.path_build.path}')
	if true{
		panic("555")
	}	
	// execute('rsync -a ${dir(@FILE)}/tmp_content/ ${dir(@FILE)}/content/')
	// rmdir_all('${dir(@FILE)}/tmp_content')!
	// os.mv('${site.path_build.path}/public', site.path_publish.path)!
}
