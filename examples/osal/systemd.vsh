#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.osal.systemd
import freeflowuniverse.crystallib.installers.infra.zinit as zinitinstaller

zinitinstaller.install()!

println("zinit installed")

mut systemdfactory := systemd.new()!
mut systemdprocess := systemdfactory.new(
	cmd: '/usr/local/bin/zinit init'
	name: 'zinit'
	description: 'a super easy to use startup manager.'
)!

l:=systemd.process_list()!
println(l)
