module main

import freeflowuniverse.crystallib.osal { exec }

fn do() ! {
	exec(
		cmd: 'eecho sometext'
		remove_installer: false
		reset: false
		retry: 5
		period: 10
	) or {
		println(err.code())
		assert err.code() == 127
	}
	// should print code 127

	exec(
		cmd: 'eecho sometext'
		ignore_error_codes: [127]
		retry: 5
	)!

	r := exec(
		cmd: 'echo sometext'
		ignore_error_codes: [127]
		retry: 5
	)!

	println(r)

	println('echo ok ')
}

fn main() {
	do() or { panic(err) }
}
