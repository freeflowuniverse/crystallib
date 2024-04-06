#!/usr/bin/env -S v -w -enable-globals run


import freeflowuniverse.crystallib.sysadmin.startupmanager

mut sm:=startupmanager.get()!

sm.start(
    name: 'mytest'
    cmd: 'htop'
)!

