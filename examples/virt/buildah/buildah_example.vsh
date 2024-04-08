#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.virt.buildah
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.base
// import freeflowuniverse.crystallib.builder
import time

import os

//interative means will ask for login/passwd

console.print_header("BuildAH Demo.")

mut session := play.session_new()!

