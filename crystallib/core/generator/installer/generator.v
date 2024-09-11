module installer

import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui.console

pub fn scan(path_ string) ! {
	// mut args := args_
	mut path := path_

	if path.len == 0 {
		path = os.getwd()
	}

	// now walk over all directories, find .heroscript
	mut pathroot := pathlib.get_dir(path: path, create: false)!
	mut plist := pathroot.list(
		recursive: true
		ignoredefault: false
		regex: [
			'\\.heroscript',
		]
	)!

	for mut p in plist.paths {
		pparent := p.parent()!
		// println("-- ${pparent}")
		generate(pparent.path)!
	}
}

pub struct GeneratorArgs {
pub mut:
	name                  string   @[required]
	classname             string   @[required]
	default               bool // means user can just get the object and a default will be created
	title                 string
	supported_platforms   []string
	configure_interactive bool
	singleton             bool // means there can only be one
	templates             bool
	reset                 bool // regenerate all, dangerous !!!
	startupmanager        bool = true
	build                 bool
}

pub fn generate(path string) ! {
	console.print_debug('generate installer code for path: ${path}')

	mut config_path := pathlib.get_file(path: '${path}/.heroscript', create: false)!

	if !config_path.exists() {
		return error("can't find path with .heroscript in ${path}")
	}

	mut plbook := playbook.new(text: config_path.read()!)!

	mut install_actions := plbook.find(filter: 'hero_code.generate_installer')!
	if install_actions.len > 0 {
		for install_action in install_actions {
			mut p := install_action.params
			mut args := GeneratorArgs{
				name: p.get('name')!
				classname: p.get('classname')!
				title: p.get_default('title', '')!
				default: p.get_default_true('default')
				supported_platforms: p.get_list('supported_platforms')!
				singleton: p.get_default_false('singleton')
				templates: p.get_default_false('templates')
				reset: p.get_default_false('reset')
				startupmanager: p.get_default_true('startupmanager')
				build: p.get_default_false('build')
			}

			mut path_actions := pathlib.get(path + '/${args.name}_actions.v')
			if !path_actions.exists() || args.reset {
				println('actions doesnt exists or reset = ${args.reset}')
				mut templ_1 := $tmpl('templates/objname_actions.vtemplate')
				pathlib.template_write(templ_1, '${path}/${args.name}_actions.vtemplate',
					true)!
			}

			mut templ_2 := $tmpl('templates/objname_factory_.vtemplate')
			pathlib.template_write(templ_2, '${path}/${args.name}_factory_.vtemplate',
				true)!

			mut path_model := pathlib.get(path + '/${args.name}_model.v')
			if args.reset || !path_model.exists() {
				println('model doesnt exists or reset = ${args.reset}')
				mut templ_3 := $tmpl('templates/objname_model.vtemplate')
				pathlib.template_write(templ_3, '${path}/${args.name}_model.vtemplate',
					true)!
			}

			mut templ_4 := $tmpl('templates/objname_runner_.vtemplate')
			pathlib.template_write(templ_4, '${path}/${args.name}_runner_.vtemplate',
				true)!

			mut templ_5 := $tmpl('templates/readme.md')
			pathlib.template_write(templ_5, '${path}/readme.md', true)!

			if args.templates {
				// create template dir
				mut path_templ_dir := pathlib.get_dir(path: path + '/templates', create: false)!
				if args.reset {
					path_templ_dir.delete()!
				}
				// if true{
				// 	println(path_templ_dir)
				// 	println(path_templ_dir.exists())
				// 	panic("sss")
				// }
				if !path_templ_dir.exists() {
					mut templ_6 := $tmpl('templates/atemplate.yaml')
					pathlib.template_write(templ_6, '${path}/templates/atemplate.yaml',
						true)!
				}
			}
		}
	}
}

fn platform_check(args GeneratorArgs) ! {
	ok := 'osx,ubuntu,arch'
	ok2 := ok.split(',')
	for i in args.supported_platforms {
		if i !in ok2 {
			return error('cannot find ${i} in choices for supported_platforms. Valid ones are ${ok}')
		}
	}
}

pub fn (args GeneratorArgs) platform_check_str() string {
	mut out := ''

	if 'osx' in args.supported_platforms {
		out += 'myplatform == .osx || '
	}
	if 'ubuntu' in args.supported_platforms {
		out += 'myplatform == .ubuntu ||'
	}
	if 'arch' in args.supported_platforms {
		out += 'myplatform == .arch ||'
	}
	out = out.trim_right('|')
	return out
}
