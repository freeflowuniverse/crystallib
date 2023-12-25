#!/usr/bin/env v -enable-globals run

import freeflowuniverse.crystallib.installers.bashscripts
import os

mypath:=bashscripts.bash_installers_package()!


res := os.execute("bash ${mypath}/installer.sh")
// println(res)
if res.exit_code > 0 {
	// println(cmd)
	println('Could not run the installer, just to check if there are no syntax errors.\n${res.output}')
	exit(1)
}

println(" - packaged succesfully")