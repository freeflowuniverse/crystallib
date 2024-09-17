#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.installers.threefold.griddriver
def_heroscript := griddriver.heroscript_default()
griddriver.play(heroscript: def_heroscript)!
mut griddriver_installer := griddriver.get()!
griddriver_installer.install()!
