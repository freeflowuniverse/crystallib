#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run


import freeflowuniverse.crystallib.hero.bootstrap

mut al:=bootstrap.new_alpine_loader()

al.start()!