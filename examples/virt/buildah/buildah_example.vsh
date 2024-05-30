#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.virt.podman
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
// import freeflowuniverse.crystallib.builder
import time

import os

//interative means will ask for login/passwd

console.print_header("BUILDAH Demo.")

mut pm:=podman.new()!

mut b:=pm.bcontainer_new(name:"test")!


// pm.builderv()!


mut b2:=pm.bcontainer_get("builderv")!
b2.shell()!


