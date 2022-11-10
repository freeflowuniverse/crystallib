module planner

import os

// Note: T should be passed a struct name only
fn obj_new<T>(path string) ?T {
	lines := os.read_lines(path)?
	mut obj := T{}
	obj.load(lines)?
	// println('$T')
	panic('s')
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type
	// $for field in T.fields {
	// 	$if field.typ is string {
	// 		// $(string_expr) produces an identifier
	// 		result.$(field.name) = data
	// 	} $else $if field.typ is int {
	// 		result.$(field.name) = 1
	// 	}
	// }
	return obj
}

// fn (mut site Site) file_remember(path string, name string) &File {
// 	mut namelower := texttools.name_fix(name)
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
// 		if site.planner.files.len == 0 {
// 			site.planner.files = []File{}
// 		}

// 		file := File{
// 			id: site.planner.files.len
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
