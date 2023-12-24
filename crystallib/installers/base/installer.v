module base

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install base will return true if it was already installed
pub fn install(args InstallArgs) ! {
	println('platform prepare')
	pl := osal.platform()

	if args.reset == false && osal.done_exists('platform_prepare') {
		println('Platform already prepared')
		return
	}

	if pl == .osx {
		println(' - OSX prepare')
		if !osal.cmd_exists('brew') {
			osal.execute_interactive('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"') or {
				return error('cannot install brew, something went wrong.\n${err}')
			}
		}
		osal.exec(
			cmd: '
		brew update
		brew install mc tmux git rsync curl tmux
		'
		)!
	} else if pl == .ubuntu {
		println(' - Ubuntu prepare')
		osal.execute_silent('
		apt update
		apt install iputils-ping net-tools git rsync curl mc tmux libsqlite3-dev xz-utils -y
		')!
	} else {
		panic('only ubuntu and osx supported for now')
	}
	osal.done_set('platform_prepare', 'OK')!
}

pub fn develop(args InstallArgs) ! {
	println('platform prepare')
	pl := osal.platform()

	if args.reset == false && osal.done_exists('crystal_development') {
		println(' - V & Crystallib Already installed for development.')
		return
	}

	install()!
	if pl == .osx {
		println(' - OSX prepare for development.')
		osal.package_install('bdw-gc')!
		if !osal.cmd_exists('clang') {
			osal.execute_silent('xcode-select --install') or {
				return error('cannot install xcode-select --install, something went wrong.\n${err}')
			}
		}
	} else if pl == .ubuntu {
		println(' - Ubuntu prepare')
		osal.package_install('libgc-dev,gcc,make,libpq-dev')!
	} else {
		panic('only ubuntu and osx supported for now')
	}

	coderoot := '${os.home_dir()}/code_'
	iam := osal.whoami()!
	cmd := pathlib.template_replace($tmpl('templates/vinstaller.sh'))
	osal.exec(cmd: cmd)!

	mut gs := gittools.get()!

	mut path := gittools.code_get(
		pull: false
		reset: false
		url: 'https://github.com/freeflowuniverse/crystallib/tree/development'
	)!

	mut path2 := gittools.code_get(
		pull: true
		reset: false
		url: 'https://github.com/freeflowuniverse/webcomponents.git'
	)!

	c := '
	echo - link modules
	mkdir -p ~/.vmodules/freeflowuniverse
	rm -f ~/.vmodules/freeflowuniverse/crystallib
	rm -f ~/.vmodules/freeflowuniverse/webcomponents
	ln -s ${path}/crystallib ~/.vmodules/freeflowuniverse/crystallib
	ln -s ${path2}/webcomponents ~/.vmodules/freeflowuniverse/webcomponents
			
	'
	osal.exec(cmd: c)!

	hero(args)!

	osal.done_set('crystal_development', 'OK')!
}

pub fn hero(args InstallArgs) ! {
	pl := osal.platform()

	cmd_hero := pathlib.template_replace($tmpl('templates/hero.sh'))
	osal.exec(cmd: cmd_hero, stdout: false)!
}
