#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.virt.docker

mut engine := docker.new()!

engine.reset_all()!

println(engine)

