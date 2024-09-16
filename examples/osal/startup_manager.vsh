#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.installers.infra.zinit as zinitinstaller
import freeflowuniverse.crystallib.sysadmin.startupmanager

zinitinstaller.install()!

println("zinit installed")

cmd:= '/usr/local/bin/zinit init'
name:= 'zinit'

mut sm := startupmanager.get()!
println(sm.list()!)
sm.start(
	name: name
	cmd: cmd
)!

println(sm.list()!)
assert sm.exists(name)!

sm.delete(name)!