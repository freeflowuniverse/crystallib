module vault

import freeflowuniverse.crystallib.core.pathlib

// walk over folders, find the vaults and delete them
pub fn vaults_delete(mut path pathlib.Path) ! {
	mut pl:=path.list(recursive: true)!
	for mut p in pl.paths {
		if p.is_dir() {
			if p.name() == '.vault' {
				p.delete()!
			}
		}
	}
}
