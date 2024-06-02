#!/usr/bin/env -S v -w -n -enable-globals run

import freeflowuniverse.crystallib.virt.podman
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
// import freeflowuniverse.crystallib.builder
import time

import os

//interative means will ask for login/passwd

mut engine:=podman.new(install:false,herocompile:true)!

//engine.reset_all()!

mut builder_gorust := engine.builder_go_rust()!

//will build nodejs, python build & crystallib, hero
mut builder_crystal := engine.builder_crystal(reset:true)!

mut builder_web := engine.builder_heroweb(reset:true)!



builder_web.shell()!


