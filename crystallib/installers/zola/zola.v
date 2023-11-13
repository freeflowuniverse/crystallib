module zola

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.rust

// install zola will return true if it was already installed
pub fn install() ! {
	rust.install()!
	println(' - install zola')
	if !osal.done_exists('install_zola') && !osal.cmd_exists('zola') {

		// USE OUR PRIMITIVES (TODO, needs to change)
		cmd:='
		cd /tmp
		rm -rf zola
		git clone https://github.com/getzola/zola.git
		cd zola
		cargo install --path . --locked
		zola --version
		cargo build --release --locked --no-default-features --features=native-tls
		cp target/release/zola ~/.cargo/bin/zola
		'
		osal.execute_stdout(cmd)!
		osal.done_set('install_zola', 'OK')!
		println(' - zola installed')
	}else{
		println(' - zola already installed')
	}

}

// https://www.getzola.org/documentation/getting-started/installation/