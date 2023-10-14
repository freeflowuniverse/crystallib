module vault

import freeflowuniverse.crystallib.core.pathlib

// walk over folders, find the vaults and delete them
pub fn vaults_delete(mut path pathlib.Path) ! {
	for mut p in path.list(recursive: true)! {
		if p.is_dir() {
			if p.name() == '.vault' {
				p.delete()!
			}
		}
	}
}
