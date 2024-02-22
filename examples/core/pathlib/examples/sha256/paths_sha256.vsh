#!/usr/bin/env -S v -w -cg -enable-globals run

import freeflowuniverse.crystallib.core.pathlib
import os

const testpath4 = os.dir(@FILE) + '/paths_sha256.vsh'

mut p := pathlib.get_file(path: testpath4)!
s := p.sha256()!
println(s)