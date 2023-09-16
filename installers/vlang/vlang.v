module vlang

// install vlang will return true if it was already installed
pub fn  install() ! {

	// install vlang if it was already done will return true
	println(' - ${node.name}: install vlang')
	if !(i.state == .reset) && osal.done_exists('install_vlang') {
		println('    ${node.name}: was already done')
		return
	}

	if cmd_exists('v') {
		println('Vlang was already installed.')
		return
	}
	cmd := '
	apt install make build-essential -y
	cd /root
	git clone https://github.com/vlang/v
	cd v
	make
	./v symlink
	'

	osal.exec_silent('Cannot install vlang.\n${err}')!

osal.done_set('install_vlang', 'OK')!
	return
}
