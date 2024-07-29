module vlang

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os
// import freeflowuniverse.crystallib.sysadmin.downloader


pub fn v_analyzer_install(args_ InstallArgs) ! {
	mut args := args_
	version := '0.0.4'

	res := os.execute('${osal.profile_path_source_and()} v-analyzer version')
	if false && res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().starts_with('v-analyzer'))
		if r.len != 1 {
			return error("couldn't parse v-analyzer version.\n${res.output}")
		}
		myversion := r[0].all_after_first('version').trim_space()
		// if texttools.version(version) > texttools.version(r[0].all_after_first('v-analyzer-')) {
		if myversion != version {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		console.print_debug('v-analyzer already installed')
		return
	}

	install()!

	if args.reset {
		console.print_header('install v-analyzer')

		mut url := ''
		if osal.is_linux_intel() {
			url = 'https://github.com/vlang/v-analyzer/releases/download/nightly/v-analyzer-linux-x86_64.zip'
		} else if osal.is_osx_arm() {
			url = 'https://github.com/vlang/v-analyzer/releases/download/nightly/v-analyzer-darwin-arm64.zip'
		} else if osal.is_osx_intel() {
			url = 'https://github.com/vlang/v-analyzer/releases/download/nightly/v-analyzer-darwin-x86_64.zip'
		} else {
			return error('unsported platform for installing v-analyzer')
		}

		mut dest := osal.download(
			url: url
			minsize_kb: 1000
			expand_dir: '/tmp/v-analyzer'
		)!

		mut binpath := dest.file_get('v-analyzer')!
		osal.cmd_add(
			cmdname: 'v-analyzer'
			source: binpath.path
		)!
	}

	// if args.reset == false && osal.done_exists('install_v_analyzer') {
	// 	console.print_debug('   v analyzer already installed')
	// 	return
	// }
	// console.print_header('install v analyzer')

	// cmd := '
	// 	cd /tmp
	// 	export TERM=xterm
	// 	source ~/.profile
	// 	rm -f install.sh
	// 	curl -fksSL https://raw.githubusercontent.com/v-lang/v-analyzer/master/install.vsh > install.vsh
	// 	v run install.vsh  --no-interaction
	// 	'
	// osal.execute_stdout(cmd) or { return error('Cannot install hero.\n${err}') }

	osal.done_set('install_v_analyzer', 'OK')!
	return
}
