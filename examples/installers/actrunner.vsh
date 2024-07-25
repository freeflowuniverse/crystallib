#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.installers.sysadmintools.actrunner
import freeflowuniverse.crystallib.installers.virt.podman

actrunner.install()!
//podman.start()!