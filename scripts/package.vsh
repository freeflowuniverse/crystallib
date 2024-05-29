#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.installers.base

import os

mypath:=base.bash_installers_package()!


res := os.execute("bash ${mypath}/install_base.sh")
// println(res)
if res.exit_code > 0 {
	// println(cmd)
	println('Could not run the installer, just to check if there are no syntax errors.\n${res.output}')
	exit(1)
}

println(" - packaged succesfully")