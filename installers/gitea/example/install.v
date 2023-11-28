module main

import installers.gitea

fn do() ! {
	mut g := gitea.new(
		passwd: '123'
		postgresql_path: '/tmp/db'
		postgresql_reset: true
		domain: 'git.meet.tf'
		appname: 'ourworld'
	)!
	// postgresql will be same passwd
	println('debug00: ${g}')
	g.restart()!
}

fn main() {
	do() or { panic(err) }
}
