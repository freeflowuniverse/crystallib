#!/usr/bin/env -S v -w -cg -enable-globals run

import freeflowuniverse.crystallib.installers.lang.vlang
import freeflowuniverse.crystallib.installers.sysadmintools.dagu as dagu_installer
import freeflowuniverse.crystallib.installers.sysadmintools.b2 as b2_installer

vlang.v_analyzer_install()!
dagu_installer.install()!

