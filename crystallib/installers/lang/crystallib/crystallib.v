module crystallib

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// install crystallib will return true if it was already installed

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	// install crystallib if it was already done will return true
	console.print_header('install crystallib')
	if  args.reset==false && osal.done_exists('install_crystaltools') {
		println('    package_install was already done')
		return
	}
	cmd:="
		cd /tmp
		export TERM=xterm
		curl https://raw.githubusercontent.com/freeflowuniverse/crystallib/development/scripts/installer.sh > /tmp/install.sh
		bash /tmp/install.sh
		"
	osal.execute_stdout(cmd) or {
		return error('Cannot install crystallib.\n${err}')
	}
	osal.done_set('install_crystaltools', 'OK')!
	return
}


pub fn hero_install(args InstallArgs) ! {
	if  args.reset==false && osal.done_exists('install_hero') {
		println('    package_install was already done')
		return
	}
	console.print_header('install hero')
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
