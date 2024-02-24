module vlang

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.develop.gittools


pub fn install(args InstallArgs) ! {
	// install vlang if it was already done will return true
	if  args.reset==false && osal.done_exists('install_vlang') {
		// println('   v already installed')
		return
	}
	console.print_header('install vlang')
	base.develop()!
	
	mut gs := gittools.new(
			root:"${os.home_dir()}/_code"
			light: true
			singlelayer: true
			)!
	mut path1 := gs.code_get(
		pull: true
		reset: true
		url: 'https://github.com/vlang/v/tree/master'
	)!

	mut extra:=""
	if osal.is_linux(){
		extra="./v symlink"
	}else{
		extra="cp v ${os.home_dir()}/bin/"
	}
	cmd := '
	cd ${path1}
	make	
	${extra}
	'
	console.print_header('compile')
	osal.exec(cmd:cmd,stdout:true)!
	console.print_header('compile done')

	osal.done_set('install_vlang', 'OK')!
	return
}


@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn v_analyzer_install(args InstallArgs) ! {
	if  args.reset==false && osal.done_exists('install_v_analyzer') {
		println('   v analyzer already installed')
		return
	}
	install()!
	console.print_header('install v analyzer')
	cmd:="
		cd /tmp
		export TERM=xterm
		source ~/.profile
		rm -f install.sh
		curl -fksSL https://raw.githubusercontent.com/v-analyzer/v-analyzer/master/install.vsh > install.vsh
		v run install.vsh  --no-interaction
		"
	osal.execute_stdout(cmd) or {
		return error('Cannot install hero.\n${err}')
	}
	osal.done_set('install_v_analyzer', 'OK')!
	return
}

