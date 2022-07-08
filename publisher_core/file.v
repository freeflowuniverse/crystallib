module publisher_core

import os
import freeflowuniverse.crystallib.path

fn (mut file File) consumer_page_register(page_id_source int, mut publisher Publisher) {
	page := publisher.page_get_by_id(page_id_source) or { panic(err) }
	if page.site_id != file.site_id {
		panic('can only register page for same site, is bug (site:${file.name(mut publisher)}:$file.site_id)\n$page\n')
	}
	if page_id_source !in file.usedby {
		file.usedby << page_id_source
	}
}

// also need to make sure its in right directory
// do this after the loading/checking of all pages & files
fn (mut file File) relocate(mut publisher Publisher) ? {
	if file.site_id > publisher.sites.len {
		panic('cannot find site: $file.site_id, not enough elements in list.')
	}
	mut site := publisher.sites[file.site_id]
	mut path := file.path_get(mut publisher)?
	mut dest := ''
	mut m := map[string]int{}
	mut page_strings := []string{}

	if path.contains('testcontent/') {
		return
	}

	if path.ends_with('.pdf') || path.ends_with('zip') {
		return
	}

	if file.usedby.len > 0 {
		// println(" >> relocate in ${file.name} used")
		if file.usedby.len > 1 {
			page_strings = []
			// println(" >> file used multiple times for ${file.path_get(mut publisher)}")
			for pageid_who_has_file in file.usedby {
				page_file := publisher.page_get_by_id(pageid_who_has_file) or { panic(err) }
				page_strings << page_file.path
				m[page_file.path] = pageid_who_has_file
				// println("     - ${page_file.path_get(mut publisher)}")
			}
			page_strings.sort()
			page_id_found := m[page_strings[0]]
			mut page_file2 := publisher.page_get_by_id(page_id_found) or { panic(err) }
			// this is the page which has first part in sorted list, is like the master which will hold the file
			page_path2 := page_file2.path_get(mut publisher)
			dest = os.dir(page_path2) + '/img/${os.base(path)}'
			if dest.replace('//', '/').trim(' /') == path.replace('//', '/').trim(' /') {
				// this means the file we are looking at is on right path, nothing to do
				return
			}
			if os.exists(dest) {
				if os.real_path(dest) == os.real_path(path) {
					return error('should never be same path: $dest and $path')
				}
				// println('   >>>RM3: $path')
				// os.rm(path) ?
			} else {
				println('   >>>MV3: $path -> $dest')
				file.mv(mut publisher, dest)?
			}
		} else {
			pageid_who_has_file := file.usedby[0]
			mut page_file := publisher.page_get_by_id(pageid_who_has_file) or { panic(err) }
			page_path := page_file.path_get(mut publisher)
			dest = os.dir(page_path) + '/img/${os.base(path)}'
			if dest.replace('//', '/').trim(' /') == path.replace('//', '/').trim(' /') {
				return
			}
			if !os.exists(dest) {
				println(" >>>MV2: '$path' -> '$dest'")
				file.mv(mut publisher, dest)?
			}
		}
	} else {
		if path.contains('img_notused') {
			return
		}
		// println("${file.name} not used")
		dest = '$site.path/img_notused/${os.base(path)}'
		if !os.exists(dest) {
			println('>>>MV5: $path -> $dest')
			file.mv(mut publisher, dest)?
		}
	}
	// file.path = '/img_notused/${os.base(path)}'
}

// mark this file as duplicate from other file
pub fn (mut file File) duplicate_from(mut publisher Publisher, mut fileother File) ? {
	file.delete(mut publisher)?
	for idd in file.usedby {
		if idd !in fileother.usedby {
			fileother.usedby << idd
		}
	}
	file.usedby = []
}

pub fn (mut file File) delete(mut publisher Publisher) ? {
	file.state = FileStatus.deleted
	path := file.path_get(mut publisher)?
	if os.exists(path) {
		os.rm(path)?
	}
	file.state = .deleted
	file.usedby = []
}

pub fn (mut file File) mv(mut publisher Publisher, dest string) ? {
	path_file := file.path_get(mut publisher)?
	os.mkdir_all(os.dir(dest))?
	mut desto := path.get_file_dir_create(dest)?
	os.mv(path_file, desto.path_absolute()) or {
		return error('could not rename $path_file to $desto.path_absolute() .\n$err\n$file')
	}
	site := file.site_get(mut publisher)?
	// need to get relative path in, in relation to site
	file.pathrel = desto.path_relative(site.path)
}

pub fn (mut file File) exists(mut publisher Publisher) ?bool {
	if file.state == FileStatus.deleted {
		return false
	}
	// return the full path
	path := file.path_get(mut publisher)?
	return os.exists(path)
}
