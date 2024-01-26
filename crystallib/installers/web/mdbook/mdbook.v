module mdbook

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.lang.rust
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install mdbook will return true if it was already installed
pub fn install(args_ InstallArgs) ! {
	mut args := args_

	res := os.execute('source ${osal.profile_path()} && mdbook --version')
	if res.exit_code == 0 {
		v:=texttools.version(res.output)
		if v<4036 {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install mdbook')
	if false && osal.cmd_exists("nix-env"){
		osal.package_install("mdbook,mdbook-toc,mdbook-pdf,mdbook-mermaid,mdbook-footnote,mdbook-linkcheck,mdbook-kroki-preprocessor")!
	}else{
		build()!			
	}

}


// install mdbook will return true if it was already installed
pub fn build() ! {
	console.print_header('build mdbook')
	rust.install()!
	cmd := '
	source ~/.cargo/env
	cargo install mdbook
	cargo install mdbook-mermaid
	cargo install mdbook-echarts
	cargo install mdbook-embed
	#cargo install mdbook-plantuml
	cargo install mdbook-kroki-preprocessor
	cargo install mdbook-pdf --features fetch
	cargo install mdbook-linkcheck
	
	'
	osal.execute_stdout(cmd)!
	osal.done_set('install_mdbook', 'OK')!
	console.print_header('mdbook installed')
}
