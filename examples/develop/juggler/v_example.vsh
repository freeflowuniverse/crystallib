#!/usr/bin/env -S v -w -n -enable-globals run

import freeflowuniverse.crystallib.develop.juggler
import veb

mut j := juggler.get(
	repo_path: '/root/code/git.ourworld.tf/projectmycelium/itenv'
	dagu_url: 'http://65.21.132.119:8888/api/v1/'
)!

j.run(8200)!

// TODO
// - automate caddy install/start
// - create server/caddy which only calls install & can set config file from path or url & restart (see dagu server)
// - get caddy config from the itenv through (simple driver)
// - caddy through startup manager, also for dagu
// - expose dagu UI over caddy & make sure we use secret
// - have heroscript starting from itenv to start a full env (with secret): 'hero juggler -i -s mysecret --dns juggler2.protocol.me '
// - use domain name use https://github.com/Incubaid/dns/blob/main/protocol.me.lua  over git ssh
