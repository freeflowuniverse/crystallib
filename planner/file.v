module planner

import os

// fn (mut planner planner) file_remember(path path.Path) &File {
// 	mut namelower := textools.name_fix(name) or { panic(err) }
// 	mut pathfull_fixed := os.join_path(path, namelower)
// 	mut pathfull := os.join_path(path, name)
// 	if pathfull_fixed != pathfull {
// 		os.mv(pathfull, pathfull_fixed) or { panic(err) }
// 		pathfull = pathfull_fixed
// 	}
// 	// now remove the root path
// 	pathrelative := pathfull[site.path.len..]
// 	// println(' - File $namelower <- $pathfull')
// 	if site.file_exists(namelower) {
// 		// error there should be no duplicates
// 		site.errors << SiteError{
// 			path: pathrelative
// 			error: 'duplicate file $pathrelative'
// 			cat: SiteErrorCategory.duplicatefile
// 		}
// 	} else {
// 		if publisher.files.len == 0 {
// 			publisher.files = []File{}
// 		}

// 		file := File{
// 			id: publisher.files.len
// 			site_id: site.id
// 			name: namelower
// 			path: pathrelative
// 		}
// 		// println("remember site: $file.name")
// 		publisher.files << file
// 		site.files[namelower] = publisher.files.len - 1
// 	}
// 	file0 := site.file_get(namelower, ) or { panic(err) }
// 	if file0.site_id > 1000 {
// 		panic('cannot be')
// 	}
// 	return file0
// }



pub enum FileStatus {
	unknown
	ok
	error
}

pub struct File {
	id      int [skip]
	site_id int [skip]
pub mut:
	name   string
	path   string
	state  FileStatus
	usedby []int // names of pages which use this file
}

// pub fn (file File) site_get() ?&Site {
// 	return publisher.site_get_by_id(file.site_id)
// }

// pub fn (file File) path_relative_get() string {
// 	if file.path == '' {
// 		panic('file path should never be empty, is bug')
// 	}
// 	return file.path
// }

// pub fn (file File) path_get() string {
// 	if file.site_id > publisher.sites.len {
// 		panic('cannot find site: $file.site_id, not enough elements in list.')
// 	}
// 	if file.path == '' {
// 		panic('file path should never be empty, is bug. For file\n$file')
// 	}
// 	site_path := publisher.sites[file.site_id].path
// 	return os.join_path(site_path, file.path)
// }

// // get the name of the file with or without site prefix, depending if file is in the site
// pub fn (file File) name_get( site_id int) string {
// 	site := file.site_get() or { panic(err) }
// 	if site.id == site_id {
// 		return file.name
// 	} else {
// 		return '$site.name:$file.name'
// 	}
// }
