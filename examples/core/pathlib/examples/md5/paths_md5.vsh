#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.core.pathlib
import os

const testpath4 = os.dir(@FILE) + '../../'

mut p := pathlib.get_file(path: os.dir(@FILE) + '/paths_md5.vsh')!

md5hash := p.md5hex()!
println('file md5 hash: ${md5hash}')

file_size_bytes := p.size()!
println('size in bytes: ${file_size_bytes}')

file_size_kbytes := p.size_kb()!
println('size in kb: ${file_size_kbytes}')
