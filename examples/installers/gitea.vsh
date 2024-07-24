#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.installers.gitea

mut g := gitea.new(
	passwd: '123'
	postgresql_path: '/tmp/db'
	postgresql_reset: true
	domain: 'git.meet.tf'
	appname: 'ourworld'
)!
// postgresql will be same passwd
g.restart()!
