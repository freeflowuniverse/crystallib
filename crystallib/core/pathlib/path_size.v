module pathlib

import os
import freeflowuniverse.crystallib.ui.console

pub fn (mut path Path) size_kb() !int {
	s := path.size()!
	return int(s / 1000)
}

pub fn (mut path Path) size() !f64 {
	path.check_exists()!
	// console.print_header(' filesize: $path.path")
	if path.cat == .file {
		return os.file_size(path.path)
	} else {
		mut pl := path.list(recursive: true)!
		mut totsize := 0.0
		for mut p in pl.paths {
			totsize += p.size()!
		}
		return totsize
	}
}
