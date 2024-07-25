#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.installers.lang.vlang
import freeflowuniverse.crystallib.servers.daguserver
import freeflowuniverse.crystallib.installers.sysadmintools.b2 as b2_installer

vlang.v_analyzer_install()!
daguserver.new()! //will install & start a daguserver

