#!/usr/bin/env v -w -cg -enable-globals run

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.installers.web.mdbook as mdbookinstaller
import freeflowuniverse.crystallib.installers.sysadmintools.restic
import freeflowuniverse.crystallib.installers.web.zola
import os

//TODO: fix, not working, is the old one

console.print_header('Install some tools')
mdbookinstaller.install()!
// restic.install()!
// zola.install()!


console.print_header("Some test with mdbook.")

