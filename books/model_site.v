module books

import os
import freeflowuniverse.crystallib.pathlib { Path, find_common_ancestor }
import freeflowuniverse.crystallib.texttools

enum SiteType {
	book
	wiki
	web
}

[heap]
pub struct Site {
pub:
	name     string
	sites    &Sites   [str: skip] // pointer to sites
	sitetype SiteType
pub mut:
	pages  map[string]Page
	files  map[string]File
	path   pathlib.Path
	errors []SiteError
}

// walk over one specific site, find all files and pages
pub fn (mut site Site) scan() ? {
	site.scan_internal(mut site.path)?
}

enum ErrorCat {
	unknown
	image_double
	file_double
	file_not_found
	page_not_found
	sidebar
}

struct SiteErrorArgs {
	path pathlib.Path
	msg  string
	cat  ErrorCat
}

struct SiteError {
	path pathlib.Path
	msg  string
	cat  ErrorCat
}

pub fn (mut site Site) error(args SiteErrorArgs) {
	site.errors << SiteError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}
}

pub fn (site Site) page_get(name string) ?&Page {
	mut namelower := texttools.name_fix(name)
	if namelower in site.pages {
		mut page := site.pages[namelower]
		return &page
	}
	return error('cannot find page with name $name')
}

pub fn (site Site) file_get(name string) ?&File {
	if name.ends_with('.png') || name.ends_with('.jpeg') || name.ends_with('.jpg') {
		return site.image_get(name)
	}
	mut namelower := texttools.name_fix(name)
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .file {
			return &file
		} else {
			return error('did find file, but not an file for name:$name')
		}
	}
	return error('cannot find file with name $name')
}

pub fn (site Site) image_get(name string) ?&File {
	namelower := texttools.name_fix_no_underscore_no_ext(name)
	if namelower in site.files {
		file := site.files[namelower]
		if file.ftype == .image {
			return &file
		} else {
			return error('did find file, but not an image for name:$name')
		}
	}
	return error('cannot find image with name $name')
}

pub fn (site Site) page_exists(name string) bool {
	mut namelower := texttools.name_fix(name)
	return namelower in site.pages
}

pub fn (site Site) image_exists(name string) bool {
	_ := site.image_get(name) or { return false }
	return true
}

pub fn (site Site) file_exists(name string) bool {
	_ := site.file_get(name) or { return false }
	return true
}

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

pub fn (mut site Site) fix() ? {
	site.fix_duplicates()?
	for _, mut page in site.pages {
		page.fix()?
	}
}
