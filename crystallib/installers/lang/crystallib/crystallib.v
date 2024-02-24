module crystallib

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.lang.vlang
import freeflowuniverse.crystallib.core.texttools
import os
// install crystallib will return true if it was already installed

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	// install crystallib if it was already done will return true
	console.print_header('install crystallib')
	if  args.reset==false && osal.done_exists('install_crystallib') {
		println('    crystallib was already installed')
		return
	}
	base.develop()!
	vlang.install()!
	cmd:="
		cd /tmp
		export TERM=xterm
		export NOHERO=1
		curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
		bash /tmp/install.sh
		"
	osal.execute_stdout(cmd) or {
		return error('Cannot install crystallib.\n${err}')
	}
	osal.done_set('install_crystallib', 'OK')!
	hero_compile()!
	vlang.v_analyzer_install()!
	return
}


pub fn hero_install(args InstallArgs) ! {
	if  args.reset==false && osal.done_exists('install_hero') {
		println('    hero already installed')
		return
	}
	console.print_header('install hero')
	base.install()!	
	cmd:="
		cd /tmp
		export TERM=xterm
		curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer_hero.sh > /tmp/hero_install.sh
		bash /tmp/hero_install.sh
		"
	osal.execute_stdout(cmd) or {
		return error('Cannot install hero.\n${err}')
	}
	osal.done_set('install_hero', 'OK')!
	return
}

pub fn hero_compile(args InstallArgs) ! {
	if  args.reset==false && osal.done_exists('compile_hero') {
		println('    hero already compiled')
		return
	}
	console.print_header('compile hero')
	install()!
	base.install()!
	pl := osal.platform()
	home_dir:=os.home_dir()
	cmd_hero := texttools.template_replace($tmpl('templates/hero.sh'))
	osal.exec(cmd: cmd_hero, stdout: false)!

	osal.execute_stdout(cmd_hero) or {
		return error('Cannot compile hero.\n${err}')
	}
	osal.done_set('compile_hero', 'OK')!
	return
}


// pub fn update() ! {
// 	console.print_header('package_install update crystallib')
// 	if !(i.state == .reset) && osal.done_exists('install_crystaltools') {
// 		println('    package_install was already done')
// 		return
// 	}
// 	osal.execute_silent('cd /tmp && export TERM=xterm && source /root/env.sh && ct_upgrade') or {
// 		return error('Cannot update crystal tools.\n${err}')
// 	}
// 	osal.done_set('update_crystaltools', 'OK')!
// }
