module tfrobot

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.lang.golang
import freeflowuniverse.crystallib.osal.gittools

pub fn install() ! {
	golang.install()!
	console.print_header('install tfrobot')
	if osal.done_exists('install_tfrobot') || osal.cmd_exists('tfrobot') {
		console.print_header('tfrobot already done')
		return
	}

	path := gittools.code_get(url: 'https://github.com/threefoldtech/tfgrid-sdk-go', reset: true)!
	cmd := '
	cd ${path}
	git checkout development_run_mass_deployment
	cd mass-deployer
	make build
	sudo cp ${path}/mass-deployer/bin/tfrobot /usr/local/bin/
	'
	console.print_header('build tfrobot')
	osal.execute_stdout(cmd)!
	osal.done_set('install_tfrobot', 'OK')!
}
