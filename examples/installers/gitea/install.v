module main

import freeflowuniverse.crystallib.installers.gitea

fn do() ! {
	mut g := gitea.new(
		passwd: '123'
		postgresql_path: '/tmp/db'
		postgresql_reset: true
		domain: 'git.meet.tf'
		appname: 'ourworld'
	)!
	// postgresql will be same passwd
	g.restart()!
}

fn main() {
	do() or { panic(err) }
}
