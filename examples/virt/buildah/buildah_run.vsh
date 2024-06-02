#!/usr/bin/env -S v -w -n -enable-globals run

import freeflowuniverse.crystallib.virt.podman
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
// import freeflowuniverse.crystallib.builder
import time

import os


mut pm:=podman.new(herocompile:true)!

mut mybuildcontainer := pm.bcontainer_get("builderv")!

//bash & python can be executed directly in build container

//any of the herocommands can be executed like this
mybuildcontainer.run(cmd:"hero git list",runtime:.herocmd)!



// //following will execute heroscript in the buildcontainer
mybuildcontainer.run(
	cmd:"

	!!play.echo content:'this is just a test'

	!!play.echo content:'this is another test'

	",
	runtime:.heroscript)!

//there are also shortcuts for this

//mybuildcontainer.hero_copy()!
//mybuildcontainer.shell()!


//mut b2:=pm.bcontainer_get("builderv")!
//b2.shell()!


