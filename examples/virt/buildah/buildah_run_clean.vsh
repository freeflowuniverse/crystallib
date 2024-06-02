#!/usr/bin/env -S v -w -n -enable-globals run

import freeflowuniverse.crystallib.virt.podman
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
// import freeflowuniverse.crystallib.builder
import time

import os


mut pm:=podman.new(herocompile:true)!

mut mybuildcontainer := pm.bcontainer_get("builderv")!

mybuildcontainer.clean()!

mybuildcontainer.commit('localhost/buildersmall')!

mybuildcontainer.shell()!
