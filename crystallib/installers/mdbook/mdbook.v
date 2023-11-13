module mdbook

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.rust

// install mdbook will return true if it was already installed
pub fn install() ! {
	rust.install()!
	println(' - package_install install mdbook')
	if !osal.done_exists('install_mdbook') && !osal.cmd_exists('mdbook') {
		cmd := '
		.cargo/bin/cargo install mdbook
    	.cargo/bin/cargo install mdbook-mermaid
		.cargo/bin/cargo install mdbook-echarts
		.cargo/bin/cargo install mdbook-plantuml
		.cargo/bin/cargo install mdbook-pdf --features fetch
		'
		osal.execute_stdout(cmd)!
		osal.done_set('install_mdbook', 'OK')!
		println(' - mdbook installed')
	}else{
		println(' - mdbook already installed')
	}

}
