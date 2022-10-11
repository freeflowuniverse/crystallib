module pathlib

import os
import freeflowuniverse.crystallib.texttools

// check path exists
pub fn (mut path Path) exists() bool {
	if path.exist == .unknown {
		if os.exists(path.path) {
			path.exist = .yes
		} else {
			path.exist = .no
		}
	}
	return path.exist == .yes
}

// will rewrite the path to lower_case if not the case yet
// will also remove weird chars
// if changed will return true
pub fn (mut path Path) namefix() ?bool {
	if path.cat == .file || path.cat == .dir {
		if !path.exists() {
			return error('path $path does not exist, cannot namefix')
		}
		if texttools.name_fix(path.name()) != path.name() {
			pathnew := os.join_path(os.dir(path.path), texttools.name_fix(path.name()))
			os.mv(path.path, pathnew)?
			path.path = pathnew
			return true
		}
	}
	return false
}

// rename the file or directory
pub fn (mut path Path) rename(name string) ? {
	if name.contains('/') {
		return error("should only be a name no dir inside: '$name'")
	}
	mut dest := ''
	if path.path.contains('/') {
		before := path.path.all_before_last('/')
		dest = before + '/' + name
	} else {
		dest = name
	}
	os.mv(path.path, dest)?
	path.path = dest
	path.check()
}

// get relative path in relation to destpath
// will not resolve symlinks
pub fn (mut path Path) path_relative(destpath string) ?string {
	// println(" - path relative: '$path.path' '$destpath'")
	return path_relative(path.path, destpath)
}

// recursively finds the least common ancestor of array of paths
// will always return the absolute path (relative gets changed to absolute)
pub fn find_common_ancestor(paths_ []string) string {
	for p in paths_{
		if p.trim_space()==""{
			panic("cannot find commone ancestors if any of items in paths is empty.\n$paths_")
		}
	}
	paths := paths_.map(os.abs_path(os.real_path(it))) // get the real path (symlinks... resolved)
	// println(paths)
	parts := paths[0].split('/')
	mut totest_prev := '/'
	for i in 1 .. parts.len {
		totest := parts[0..i + 1].join('/')
		if paths.any(!it.starts_with(totest)) {
			return totest_prev
		}
		totest_prev = totest
	}
	return totest_prev
}

// find parent of path
pub fn (path Path) parent() ?Path {
	mut p := path.absolute()
	parent := os.dir(p) // get parent directory
	if parent == '.' || parent == '/' {
		return error('no parent for path $path.path')
	} else if parent == '' {
		return Path{
			path: '/'
			cat: Category.dir
			exist: .yes
		}
	}
	return Path{
		path: parent
		cat: Category.dir
		exist: .yes
	}
}

// returns extension without .
pub fn (path Path) extension() string {
	return os.file_ext(path.path).trim('.')
}

// returns extension without and all lower case
pub fn (path Path) extension_lower() string {
	return path.extension().to_lower()
}

// make sure name is normalized and jpeg becomes jpg
pub fn (mut path Path) normalize() ? {
	// println(path.extension())
	if path.extension().to_lower() == 'jpeg' {
		dest := path.path_no_ext() + '.jpg'
		println(' - RENAME: $path.path to $dest')
		os.mv(path.path, dest)?
		path.path = dest
	}
	if texttools.name_fix_keepext(path.name()) != path.name() {
		dest := path.path_dir() + '/' + texttools.name_fix_keepext(path.name())
		println(' - RENAME: $path.path to $dest')
		os.mv(path.path, dest)?
		path.path = dest
	}
}

// walk upwards starting from path untill dir or file tofind is found
// works recursive
pub fn (path Path) parent_find(tofind string) ?Path {
	if os.exists(os.join_path(path.path, tofind)) {
		return path
	}
	path2 := path.parent()?
	return path2.parent_find(tofind)
}

// delete
pub fn (mut path Path) rm() ? {
	return path.delete()
}

// delete
pub fn (mut path Path) delete() ? {
	if path.exists() {
		match path.cat {
			.file, .linkfile, .linkdir {
				os.rm(path.path)?
			}
			.dir {
				os.rmdir_all(path.path)?
			}
			.unknown {
				return error('Path cannot be unknown type')
			}
		}
		path.exist = .no
	}
}

// find dir underneith path, if exists return True
pub fn (mut path Path) dir_exists(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	mut files := os.ls(path.path) or { []string{} }
	if tofind in files {
		dir_path := os.join_path(path.path, tofind)
		if os.is_dir(dir_path) {
			return true
		}
	}
	return false
}

// find dir underneith path, return as Path
pub fn (mut path Path) dir_get(tofind string) ?Path {
	if path.dir_exists(tofind) {
		dir_path := os.join_path(path.path, tofind)
		return Path{
			path: dir_path
			cat: Category.dir
			exist: .yes
		}
	}
	return error('$tofind is not in $path.path')
}

// find file underneith path, if exists return True
pub fn (mut path Path) file_exists(tofind string) bool {
	if path.cat != Category.dir {
		return false
	}
	files := os.ls(path.path) or { []string{} }
	if tofind in files {
		file_path := os.join_path(path.path, tofind)
		if os.is_file(file_path) {
			return true
		}
	}
	return false
}

// find file underneith path, if exists return as Path, otherwise error
pub fn (mut path Path) file_get(tofind string) ?Path {
	if path.cat != Category.dir {
		return error('is not a dir: $path.path')
	}
	files := os.ls(path.path) or { []string{} }
	if tofind in files {
		file_path := os.join_path(path.path, tofind)
		if os.is_file(file_path) {
			return get_file(file_path, false)
		}
	}
	return error('')
}

// find file underneith path, return as Path, can only be one
// tofind is part of file name
pub fn (mut path Path) file_find(tofind string) ?Path {
	if path.file_exists(tofind) {
		file_path := os.join_path(path.path, tofind)
		return Path{
			path: file_path
			cat: Category.file
			exist: .yes
		}
	}
	return error('$tofind is not in $path.path')
}

// write content to the file, check is file
// if the path is a link to a file then will change the content of the file represented by the link
pub fn (mut path Path) write(content string) ? {
	if !os.exists(path.path_dir()) {
		os.mkdir_all(path.path_dir())?
	}
	if path.exists() && path.cat == Category.linkfile {
		mut pathlinked := path.readlink()?
		pathlinked.write(content)?
	}
	if path.exists() && path.cat != Category.file && path.cat != Category.linkfile {
		return error('Path must be a file for $path')
	}
	os.write_file(path.path, content)?
}

// read content from file
pub fn (mut path Path) read() ?string {
	match path.cat {
		.file, .linkfile {
			p := path.absolute()
			if !os.exists(p) {
				return error('File is not exist, $p is a wrong path')
			}
			return os.read_file(p)
		}
		else {
			return error('Path is not a file')
		}
	}
}

// copy file,dir is always recursive
// dest needs to be a directory or file
// need to check than only valid items can be done
// return Path of the destination file or dir
pub fn (mut path Path) copy(mut dest Path) ?Path {
	dest.check()
	if dest.exists() {
		if !(path.cat in [.file, .dir] && dest.cat in [.file, .dir]) {
			return error('Source or Destination path is not file or directory.\n$path.cat\n$dest.cat')
		}
		if path.cat == .dir && dest.cat == .file {
			return error("Can't copy directory to file")
		}
	}
	os.cp_all(path.path, dest.path, true)? // Always overwite if needed
	if path.cat == .file && dest.cat == .dir {
		// In case src is a file and dest is dir, we need to join the file name to the dest file
		file_name := os.base(path.path)
		dest_path := os.join_path(dest.path, file_name)
		return Path{
			path: dest_path
			cat: Category.file
			exist: .yes
		}
	}
	return Path{
		path: dest.path
		cat: dest.cat
		exist: .yes
	}
}

// recalc path between target & source
// does not touch the filesystem, is all done on string level
// we only support if source_ is an existing dir, links will not be supported
pub fn path_relative(source_ string, linkpath_ string) ?string {
	mut source := os.abs_path(source_)
	mut linkpath := os.abs_path(linkpath_)
	// now both start with /

	mut p:=get(source_)
	
	// converts file source to dir source
	if source.all_after_last('/').contains('.') {
		source = source.all_before_last('/')
		p = p.parent() or {
			return error("Parent of source $source_ doesn't exist")
		}
	}
	p.check()

	if p.cat != .dir || !p.exists() {
		return error("Cannot do path_relative()? if source is not a dir and exists. Now:$source_")
	}

	// println(" + source:$source compare:$linkpath")
	
	common := find_common_ancestor([source, linkpath])
	// println(" + common:$common")

	// if source is common, returns source
	if source.len <= common.len + 1 {
		path := linkpath_.trim_string_left(source)
		if path.starts_with('/') {
			return path[1..]
		} else {
			return path
		}
	}

	mut source_short := source[(common.len )..]
	mut linkpath_short := linkpath[(common.len)..]

	source_short=source_short.trim_string_left("/")
	linkpath_short=linkpath_short.trim_string_left("/")
	
	source_count := source_short.count('/')
	link_count := linkpath_short.count('/')
	// println (" + source_short:$source_short ($source_count)")
	// println (" + linkpath_short:$linkpath_short ($link_count)")
	mut dest := ''

	if source_short == '' { // source folder is common ancestor
		dest = linkpath_short
	} else {
		go_up := ['../'].repeat(source_count + 1).join('')
		dest = '$go_up$linkpath_short'
	}

	dest = dest.replace("//","/")
	return dest
}

// pub fn path_relative(source_ string, dest_ string) ?string {
// 	mut source := source_.trim_right('/')
// 	mut dest := dest_.replace('//', '/').trim_right('/')
// 	// println("path relative: '$source' '$dest' ")
// 	if source !="" {
// 		if source.starts_with('/') && !dest.starts_with('/') {
// 			return error('if source starts with / then dest needs to start with / as well.\n - $source\n - $dest')
// 		}
// 		if !source.starts_with('/') && dest.starts_with('/') {
// 			return error('if source starts with / then dest needs to start with / as well\n - $source\n - $dest')
// 		}
// 	}
// 	if dest.starts_with(source) {
// 		return dest[source.len..]
// 	} else {
// 		msg := "Destination path is not in source directory: $source_ $dest_"
// 		return error(msg)
// 	}
// }


