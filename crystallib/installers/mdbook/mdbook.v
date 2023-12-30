module mdbook

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.rust

// install mdbook will return true if it was already installed
pub fn install() ! {
	rust.install()!
	console.print_header('package_install install mdbook')
	if !osal.done_exists('install_mdbook') && !osal.cmd_exists('mdbook') {
		cmd := '
		source ~/.cargo/env
		cargo install mdbook
    	cargo install mdbook-mermaid
		cargo install mdbook-echarts
		#cargo install mdbook-plantuml
		cargo install mdbook-pdf --features fetch
		
		'
		osal.execute_stdout(cmd)!
		osal.done_set('install_mdbook', 'OK')!
		console.print_header('mdbook installed')
	} else {
		console.print_header('mdbook already installed')
	}
}
