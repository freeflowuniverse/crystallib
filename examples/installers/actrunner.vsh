#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.installers.sysadmintools.actrunner
import freeflowuniverse.crystallib.installers.virt.podman

actrunner.install()!
podman.install()!