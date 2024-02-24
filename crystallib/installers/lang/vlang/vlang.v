module vlang

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os



pub fn install(args InstallArgs) ! {
	// install vlang if it was already done will return true
	console.print_header('install vlang')
	if  args.reset==false && osal.done_exists('install_vlang') {
		println('   v already installed')
		return
	}

	if osal.cmd_exists('v') {
		println('Vlang was already installed.')
		return
	}

	pl := osal.platform()

	if pl==.ubuntu {
		osal.package_install('make,build-essential')!
	}

	cmd := '
	export VDIR=\'${os.home_dir()}/_code\'
	mkdir -p \$VDIR
	cd \$VDIR
	git clone https://github.com/vlang/v
	cd v
	make
	./v symlink
	'

	osal.execute_silent(cmd)!

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

