module mdbook
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.vlang

// install mdbook will return true if it was already installed
pub fn  install() ! {

	vlang.get_install()!
	println(' - package_install install mdbook')
	if !osal.done_exists('install_mdbook') && !cmd_exists('mdbook') {
		cmd := '
		.cargo/bin/cargo install mdbook
    	.cargo/bin/cargo install mdbook-mermaid
		'
		osal.execute_silent('Cannot install mdbook.\n${err}') 
		osal.done_set('install_mdbook', 'OK')!
	}
	println(' - mdbook already done')
}
