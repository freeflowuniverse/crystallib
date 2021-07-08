module publisher_core

import os

fn (mut file File) consumer_page_register(consumer_page_id int, mut publisher Publisher) {
	page := publisher.page_get_by_id(consumer_page_id) or { panic(err) }
	if page.site_id != file.site_id {
		panic('can only register page for same site, is bug (site:$file.name:$file.site_id)\n$page\n')
	}
	if !(consumer_page_id in file.usedby) {
		file.usedby << consumer_page_id
	}
}

// need to create smaller sizes if needed and change the name
// also need to make sure its in right directory
// do this after the loading/checking of all pages & files
fn (mut file File) relocate(mut publisher Publisher) {
	if file.site_id > publisher.sites.len {
		panic('cannot find site: $file.site_id, not enough elements in list.')
	}
	mut site := publisher.sites[file.site_id]
	mut path := file.path_get(mut publisher)
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
			page_path2 := page_file2.path_get(mut publisher)
			dest = os.dir(page_path2) + '/img/${os.base(path)}'
			if dest.replace('//', '/').trim(' /') == path.replace('//', '/').trim(' /') {
				return
			}
			if os.exists(dest) {
				if os.real_path(dest) == os.real_path(path) {
					panic('should never be same path: $dest and $path')
				}
				println('   >>>RM3: $path')
				os.rm(path) or { panic(err) }
			} else {
				println('   >>>MV3: $path -> $dest')
				os.mkdir_all(os.dir(dest)) or { panic(err) }
				os.mv(path, dest) or { panic(err) }
			}
		} else {
			pageid_who_has_file := file.usedby[0]
			mut page_file := publisher.page_get_by_id(pageid_who_has_file) or { panic(err) }
			page_path := page_file.path_get(mut publisher)
			dest = os.dir(page_path) + '/img/${os.base(path)}'
			if dest.replace('//', '/').trim(' /') == path.replace('//', '/').trim(' /') {
				return
			}
			if os.exists(dest) {
				if os.real_path(dest) == os.real_path(path) {
					panic('should never be same path: $dest and $path')
				}
				println(' >>>RM2: $path')
				os.rm(path) or { panic(err) }
			} else {
				println(" >>>MV2: '$path' -> '$dest'")
				os.mkdir_all(os.dir(dest)) or { panic(err) }
				os.mv(path, dest) or { panic(err) }
			}
		}
	} else {
		if path.contains('img_notused') {
			return
		}
		// println("${file.name} not used")
		dest = '$site.path/img_notused/${os.base(path)}'
		if !os.exists(dest) {
			// println(">>>MV: $path -> $dest")
			os.mkdir_all(os.dir(dest)) or { panic(err) }
			os.mv(path, dest) or { panic(err) }
		}
	}
	file.path = '/img_notused/${os.base(path)}'
}
