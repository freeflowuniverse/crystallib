module books

import os
import freeflowuniverse.crystallib.pathlib { Path, find_common_ancestor }
import freeflowuniverse.crystallib.texttools


/////TODO SHOULD NOT USE

// removes duplicates places alphabetical first to least common ancestor dir
// creates symlinks from files to old locations 
// TODO: make more memory efficient
fn (site Site) fix_duplicates() ? {
	result := os.execute("find . ! -empty -type f -exec md5sum {} + | sort")
	if result.exit_code != 0 { return error(result.output) }

	hashed_flist := result.output.split('\n')#[..-1]
	hashes := hashed_flist.map(it.all_before(' '))
	flist := hashed_flist.map(it.all_after('  '))
	reverse_hashes := hashes.reverse()

	mut duplicates := map[string][]string{}
	// loops in reverse, finds first and last index of duplicate
	for i, hash in reverse_hashes {
		first := hashes.index(hash)
		last := hashes.len - i - 1
		if first < last {
			duplicates[hash] = flist[first..last+1]
		}
	}

	$if debug {
		eprintln(@FN + '\nDuplicate files: $duplicates')
	}

	// moves .md to common ancestor and images to ancestor/img
	for hash, files in duplicates {
		mut abs_paths := files.map(Path { path: it }.absolute())
		mut new_dir := find_common_ancestor(abs_paths, site.path.absolute()) ?

		// creates img dir if not exists
		if abs_paths[0].all_after_last('.') != 'md' {
			if !new_dir.ends_with('/img') {
				new_dir = new_dir + '/img'
				if !os.exists(new_dir) {
					os.mkdir(new_dir)?
				}
			}
		}

		mut new_path := abs_paths[0]
		// moves original to new path
		if abs_paths[0].all_before_last('/') != new_dir {
			$if debug {
				eprintln(@FN + '\nMoving original to common ancestor path: $new_dir')
			}
			new_path = new_dir + '/' + abs_paths[0].all_after_last('/')
			os.mv(abs_paths[0], new_path)?
			os.symlink(new_dir, abs_paths[0])?
		}

		// removes duplicates and creates symlinks to old locations
		for fpath in abs_paths[0..] {
			$if debug {
				eprintln(@FN + '\nRemoving duplicate: $fpath')
				eprintln('Creating symlink: $new_path -> $fpath')
			}
			os.rm(fpath)?
			os.symlink(new_path, fpath)?
		}
	}
}

