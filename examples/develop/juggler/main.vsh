import freeflowuniverse.crystallib.develop.juggler

import veb

mut j := juggler.get(
	repo_path: '/root/code/git.ourworld.tf/projectmycelium/itenv',
	dagu_url: 'http://65.21.132.119:8888/api/v1/'
)!

veb.run[juggler.Juggler, juggler.Context](mut j, 8200)