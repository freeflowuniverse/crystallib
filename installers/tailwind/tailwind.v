module tailwind

// install tailwind will return true if it was already installed
pub fn  install() ! {

	// install tailwind if it was already done will return true
	println(' - package_install install tailwind')
	if !(i.state == .reset) && osal.done_exists('install_tailwind') {
		println('    package_install was already done')
		return
	}

	if cmd_exists('tailwindcss') {
		println('tailwind was already installed.')
		return
	}

	cmd := '
		curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64
		chmod +x tailwindcss-linux-x64
		mv tailwindcss-linux-x64 tailwindcss
	'

	osal.exec_silent('Cannot install tailwind.\n${err}')!

	osal.done_set('install_tailwind', 'OK')!
	return
}
