module tailwind

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_

	res := os.execute('source ${osal.profile_path()} && tailwind -help')
	if res.exit_code == 0 {
		if !(res.output.contains('tailwindcss v3.3.6')) {
			args.reset = true
			console.print_stdout("did find tailwind, but was wrong verison.")
		}
	} else {
		args.reset = true
		console.print_stdout("did not find tailwind.")
	}

	if args.reset == false && osal.done_exists('install_tailwind') {
		console.print_header('tailwind already installed')
		return
	}

	console.print_header('install tailwind')

	mut url := ''
	mut binpath_ := ''
	if osal.is_ubuntu() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.6/tailwindcss-linux-x64'
	} else if osal.is_osx_arm() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.6/tailwindcss-macos-arm64'
	} else if osal.is_osx_intel() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v3.3.6/tailwindcss-macos-x64'
	} else {
		return error('only support ubuntu & osx arm for now')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 40000
		// reset: true
	)!

	// println(dest)

	osal.cmd_add(
		cmdname: 'tailwind'
		source: dest.path
	)!

	osal.done_set('install_tailwind', 'OK')!

	return
}
