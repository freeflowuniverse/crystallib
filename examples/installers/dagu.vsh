#!/usr/bin/env -S v -n -cg -w -enable-globals run

import freeflowuniverse.crystallib.installers.sysadmintools.daguserver

mut ds := daguserver.get()!
ds.install()

println(ds)
