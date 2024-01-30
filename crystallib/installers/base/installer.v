module base

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install base will return true if it was already installed
pub fn install(args InstallArgs) ! {
	console.print_header('platform prepare')
	pl := osal.platform()

	if args.reset == false && osal.done_exists('platform_prepare') {
		console.print_header('Platform already prepared')
		return
	}

	if pl == .osx {
		console.print_header(' - OSX prepare')
		if !osal.cmd_exists('brew') {
			console.print_header(' -Install Brew')
			osal.exec(cmd:'
					/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
					(echo; echo \'eval "$(/opt/homebrew/bin/brew shellenv)"\') >> ${os.home_dir()}/.zprofile
					reset
					echo
					echo
					echo "execute: \'source ~/.zprofile\'"
					echo "or restart your shell"
					echo "and execute the hero command again"
					echo
					',stdout:true,shell:true) or {
				return error('cannot install brew, something went wrong.\n${err}')
			}			
		}
		osal.package_install('mc,tmux,git,rsync,curl,screen,redis,wget')!
		osal.exec(cmd:"
			brew services start redis
			sleep 2
			response=\$(redis-cli PING)

			# Check if the response is PONG
			if [[ \"\${response}\" == \"PONG\" ]]; then
				echo
				echo \"REDIS OK\"
			else
				echo \"REDIS CLI INSTALLED BUT REDIS SERVER NOT RUNNING\" 
				exit 1
			fi 			

		")!
	} else if pl == .ubuntu {
		console.print_header(' - Ubuntu prepare')
		osal.package_install('iputils-ping,net-tools,git,rsync,curl,mc,tmux,libsqlite3-dev,xz-utils')!
	} else if pl == .alpine {
		osal.package_install('git,curl,mc,tmux')!
	} else if pl == .arch {
		osal.package_install('git,curl,mc,tmux')!
	} else {
		panic('only ubuntu, arch, alpine and osx supported for now')
	}
	console.print_header('platform prepare DONE')
	osal.done_set('platform_prepare', 'OK')!
}

pub fn develop(args InstallArgs) ! {
	console.print_header('platform prepare')
	pl := osal.platform()

	if args.reset == false && osal.done_exists('crystal_development') {
		console.print_header(' - V & Crystallib Already installed for development.')
		return
	}

	install()!
	if pl == .osx {
		console.print_header(' - OSX prepare for development.')
		osal.package_install('bdw-gc')!
		if !osal.cmd_exists('clang') {
			osal.execute_silent('xcode-select --install') or {
				return error('cannot install xcode-select --install, something went wrong.\n${err}')
			}
		}
	} else if pl == .ubuntu {
		console.print_header(' - Ubuntu prepare')
		osal.package_install('libgc-dev,gcc,make,libpq-dev')!
	} else if pl == .alpine {
		osal.package_install('libpq-dev')!
	} else if pl == .arch {
		osal.package_install('cc,make')!
	} else {
		panic('only ubuntu and osx supported for now')
	}

	mut b := builder.new()!
	mut n := b.node_new()!
	n.crystal_install()!

	// coderoot := '${os.home_dir()}/code_'
	// iam := osal.whoami()!
	// cmd := texttools.template_replace($tmpl('templates/vinstaller.sh'))
	// osal.exec(cmd: cmd)!

	// mut path := gittools.code_get(
	// 	pull: false
	// 	reset: false
	// 	url: 'https://github.com/freeflowuniverse/crystallib/tree/development'
	// )!

	// mut path2 := gittools.code_get(
	// 	pull: true
	// 	reset: false
	// 	url: 'https://github.com/freeflowuniverse/webcomponents.git'
	// )!

	// c := '
	// echo - link modules
	// mkdir -p ~/.vmodules/freeflowuniverse
	// rm -f ~/.vmodules/freeflowuniverse/crystallib
	// rm -f ~/.vmodules/freeflowuniverse/webcomponents
	// ln -s ${path}/crystallib ~/.vmodules/freeflowuniverse/crystallib
	// ln -s ${path2}/webcomponents ~/.vmodules/freeflowuniverse/webcomponents

	// '
	// osal.exec(cmd: c)!

	// hero(args)!

	osal.done_set('crystal_development', 'OK')!
}

// compile the hero command line
pub fn hero_compile(args InstallArgs) ! {
	pl := osal.platform()

	cmd_hero := texttools.template_replace($tmpl('templates/hero.sh'))
	osal.exec(cmd: cmd_hero, stdout: false)!
}
