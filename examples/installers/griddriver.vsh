#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals -cg run

import freeflowuniverse.crystallib.installers.threefold.griddriver
def_heroscript := griddriver.heroscript_default()
griddriver.play(heroscript: def_heroscript)!
mut griddriver_installer := griddriver.get()!
griddriver_installer.install()!
