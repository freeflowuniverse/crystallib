module generic

import freeflowuniverse.crystallib.ui.console
import os

// ask all questions, set a .heroscript file in chosen path
pub fn interative() ! {
	mut myconsole := console.new()
	mut args := GeneratorArgs{}

	console.print_green('Path: ${args.path}')

	yesno := myconsole.ask_yesno(description: 'Is this path ok?')!
	if !yesno {
		return error("can't continue without a valid path")
	}

	mycat := myconsole.ask_dropdown(
		description: 'Category of the generator'
		question:    'What is the category of the generator?'
		items:       [
			'installer',
			'client',
		]
		warning: 'Please select a category'
	)!

	if mycat == 'installer' {
		args.cat = .installer
	} else {
		args.cat = .client
	}

	args.name = myconsole.ask_question(
		description: 'Name of the ${mycat}'
		question:    'What is the name of the generator?'
		warning:     'Please provide a valid name for the generator'
		minlen:      5
	)!

	args.classname = myconsole.ask_question(
		description: 'Class name of the ${mycat}'
		question:    'What is the class name of the generator e.g. MyClass ?'
		warning:     'Please provide a valid class name for the generator'
		minlen:      5
	)!

	args.title = myconsole.ask_question(
		description: 'Title of the ${mycat} (optional)'
	)!

	args.default = myconsole.ask_yesno(
		description: 'Is it ok when doing new() that a default is created?'
	)!

	// args.supported_platforms = myconsole.ask_dropdown_multiple(
	// 	description: 'Supported platforms'
	// 	question:    'Which platforms are supported?'
	// 	items:       [
	// 		'osx',
	// 		'ubuntu',
	// 		'arch',
	// 	]
	// 	warning: 'Please select one or more platforms'
	// )!

	args.singleton = myconsole.ask_yesno(
		description: 'Can there only be one instance of the object?'
	)!

	if args.cat == .installer {
		args.templates = myconsole.ask_yesno(
			description: 'Will there be templates available for your installer?'
		)!

		args.startupmanager = myconsole.ask_yesno(
			description: 'Is this an installer which will be managed by a startup mananger?'
		)!

		args.build = myconsole.ask_yesno(
			description: 'Are there builders for the installers (compilation)'
		)!
	}

	args.reset = myconsole.ask_yesno(
		description: 'Reset, overwrite code.'
		question:    'This will overwrite all files in your existing dir, be carefule?'
	)!

	create_heroscript(args)!
}

pub fn create_heroscript(args GeneratorArgs) ! {
	mut script := ''
	if args.cat == .installer {
		script = "
!!hero_code.generate_installer
    name:'${args.name}'
    classname:'${args.classname}'
    singleton:${if args.singleton {
			'1'
		} else {
			'0'
		}}
    templates:${if args.templates { '1' } else { '0' }}
    default:${if args.default {
			'1'
		} else {
			'0'
		}}
    title:'${args.title}'
    supported_platforms:''
    reset:${if args.reset {
			'1'
		} else {
			'0'
		}}
    startupmanager:${if args.startupmanager { '1' } else { '0' }}
    build:${if args.build {
			'1'
		} else {
			'0'
		}}"
	} else {
		script = "
!!hero_code.generate_client
    name:'${args.name}'
    classname:'${args.classname}'
    singleton:${if args.singleton {
			'1'
		} else {
			'0'
		}}
    default:${if args.default { '1' } else { '0' }}
    reset:${if args.reset {
			'1'
		} else {
			'0'
		}}"
	}
	if !os.exists(args.path) {
		os.mkdir(args.path)!
	}
	os.write_file('${args.path}/.heroscript', script)!
}
