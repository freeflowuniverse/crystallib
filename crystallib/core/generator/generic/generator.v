module generic

import os
import freeflowuniverse.crystallib.core.pathlib
import json
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct GeneratorArgs {
pub mut:
	name                  string
	clients               []string
	configure_interactive bool
	reset                 bool
	interactive           bool
	path                  string
}

pub struct TemplateItem {
pub mut:
	// dest string // directory where the template needs to go too
	name string // name which can be used for variable
	path string // where template is in the template dir
}

// ask the questions & generate
pub fn do(args_ GeneratorArgs) ! {
	mut args := args_

	if args.path.len == 0 {
		args.path = os.getwd()
	}

	config_path := '${args.path}/generate_config.json'

	if os.exists(config_path) && args.reset {
		os.rm(config_path)!
	}

	if os.exists(config_path) {
		mut p_config := pathlib.get_file(path: config_path)!
		config := p_config.read()!
		args = json.decode(GeneratorArgs, config)!
	} else {
		// now ask the questions if interactive
		mut myui := ui.new()!

		if args.interactive {
			console.clear()
			ok := myui.ask_yesno(
				question: "are you sure you want to generate in dir:'${args.path}'?"
			)!
			if !ok {
				return error("can't continue, user aborted.")
			}
		}

		name := args.path.trim_right('/').split('/').last() // get name of current dir

		if args.name.len == 0 {
			if args.interactive {
				args.name = myui.ask_question(
					question: '\nwhat is the name of your module?'
					default: name
				)!
			} else {
				args.name = name
			}
		}
		if args.interactive {
			args.configure_interactive = myui.ask_yesno(
				question: 'Do you want your module to configure interactively?'
			)!
		}

		if args.clients.len == 0 {
			if args.interactive {
				args.clients = myui.ask_dropdown_multiple(
					question: 'Which clients to you want?'
					items: [
						'mail',
						'postgres',
					]
				)!
			} else {
				return error('please specify build_clients')
			}
		}
		clients_check(args)!
		mut p_config := pathlib.get_file(path: config_path, create: true)!
		args.reset = false
		data := json.encode_pretty(args)
		console.print_debug('\n## Your arguments, will be saved for next time.')
		console.print_debug(args)
		p_config.write(data)!
	}
	generate(args)!
}

pub fn clients_ask(args_ GeneratorArgs) ! {
	mut args := args_
	mut myui := ui.new()!
	if args.clients.len == 0 {
		if args.interactive {
			args.clients = myui.ask_dropdown_multiple(
				question: 'Which clients to you want?'
				items: [
					'mail',
					'postgres',
				]
			)!
		} else {
			return error('please specify build_clients')
		}
	}
	clients_check(args)!
}

// generate based on the args
pub fn generate(args_ GeneratorArgs) ! {
	mut args := args_
	clients_check(args)!
	mut template_items := []TemplateItem{}

	tpath := '${args.path}/templates'
	if os.exists(tpath) {
		mut p := pathlib.get_dir(path: tpath)!
		mut pl := p.list(recursive: true)!
		for mut p_in in pl.paths {
			if p_in.exists() == false {
				return error('cannot process template file: ${p_in.path}')
			}
			if !(p_in.is_file()) {
				continue
			}
			mut p_name := p_in.name()
			if p_name.starts_with('.') {
				continue
			} else if p_name.starts_with('_') {
				continue
			}
			p_name = texttools.name_fix(p_name).replace('.', '_') + '_templ'
			relpath := p_in.path.all_after_first('/templates/')
			template_items << TemplateItem{
				name: p_name
				path: relpath
			}
		}
	}

	mut b := $tmpl('templates/configure.vtemplate')
	pathlib.template_write(b, '${args.path}/configure.v', args.reset)!

	mut c := $tmpl('templates/factory.vtemplate')
	pathlib.template_write(c, '${args.path}/factory.v', args.reset)!
}

fn clients_check(args GeneratorArgs) ! {
	ok := 'postgres,mail'
	ok2 := ok.split(',')
	for i in args.clients {
		if i !in ok2 {
			return error('cannot find ${i} in choices for clients. Valid ones are ${ok}')
		}
	}
}
