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

	res := os.execute('${osal.profile_path_source_and()} mdbook --version')
	if res.exit_code == 0 {
		v := texttools.version(res.output)
		if v < texttools.version("0.4.40") {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	for plname in ['mdbook-mermaid', 'mdbook-echarts', 'mdbook-kroki-preprocessor', 'mdbook-pdf',
		'mdbook-last-changed'] {
		if !osal.cmd_exists(plname) {
			console.print_header('did not find: ${plname}')
			args.reset = true
		}
	}

	if args.reset == false {
		return
	}

	console.print_header('install mdbook')
	build()!
}

// install mdbook will return true if it was already installed
pub fn build() ! {
	console.print_header('compile mdbook')
	rust.install()!
	mut dest_on_os := '${os.home_dir()}/hero/bin'
	if osal.is_linux() {
		dest_on_os = '/usr/local/bin'
	}	
	cmd := '
	set +ex
	rm ${os.home_dir()}/.cargo/bin/mdb* 2>&1 >/dev/null
	rm ${dest_on_os}/mdb* 2>&1 >/dev/null
	set -ex
	source ~/.cargo/env
	cargo install mdbook
	cargo install mdbook-mermaid
	cargo install mdbook-last-changed
	cargo install mdbook-echarts
	#cargo install mdbook-embed
	#cargo install mdbook-plantuml
	cargo install mdbook-kroki-preprocessor
	cargo install mdbook-pdf --features fetch
	#cargo install mdbook-linkcheck
	cp ${os.home_dir()}.cargo/bin/mdb* ${dest_on_os}/	
	'
	defer {		
		println("ERROR IN INSTALL MDBOOK, WILL ABORT")
		osal.execute_stdout("rm ${os.home_dir()}/.cargo/bin/mdb*") or {}
		osal.execute_stdout("rm ${dest_on_os}/mdb*") or {}
	}
	osal.execute_stdout(cmd)!
	osal.done_set('install_mdbook', 'OK')!
	console.print_header('mdbook installed')
}
