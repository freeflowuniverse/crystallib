module tailwind

// install tailwind will return true if it was already installed
pub fn (mut i Installer) install() ? {
	mut node := i.node
	// install tailwind if it was already done will return true
	println(' - $node.name: install tailwind')
	if !(i.state == .reset) && node.done_exists('install_tailwind') {
		println('    $node.name: was already done')
		return
	}

	if node.command_exists('tailwindcss') {
		println('tailwind was already installed.')
		return
	}

	cmd := '
		curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
		chmod +x tailwindcss-linux-x64
		mv tailwindcss-linux-x64 tailwindcss
	'

	node.exec(cmd) or { return error('Cannot install tailwind.\n$err') }

	node.done_set('install_tailwind', 'OK')?
	return
}
