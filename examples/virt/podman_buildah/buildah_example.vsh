#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.virt.podman
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base

//interative means will ask for login/passwd

mut engine:=podman.new(install:false,herocompile:true)!

engine.reset_all()!

mut builder_gorust := engine.builder_go_rust()!

//will build nodejs, python build & crystallib, hero
//mut builder_crystal := engine.builder_crystal(reset:true)!

//mut builder_web := engine.builder_heroweb(reset:true)!



builder_gorust.shell()!


