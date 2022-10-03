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
pub fn (mut path Path) path_relative(destpath string) string {
	return path_relative(path.path, destpath)
}

// recursively finds the least common ancestor of array of paths
// will always return the absolute path (relative gets changed to absolute)
pub fn find_common_ancestor(paths_ []string) string {
	paths := paths_.map(os.abs_path(os.real_path(it).trim_right('/'))) // get the real path (symlinks... resolved)
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

pub struct ListArgs {
	tofind    string // if we look for certain filter
	recursive bool   // std off, means we recursive not over dirs by default
}

// list all files & dirs, follow symlinks
// return as list of Paths
// param tofind: part of name (relative to string)
// param recursive: if recursive behaviour
pub fn (mut path Path) list(args ListArgs) ?[]Path {
	if path.cat !in [Category.dir, Category.linkdir] {
		return error('Path must be directory or link to directory')
	}
	ls_result := os.ls(path.path) or { []string{} }
	mut all_list := []Path{}
	for item in ls_result {
		p := os.join_path(path.path, item)
		mut new_path := get(p)
		// Check for dir and linkdir
		if !new_path.exists() {
			// to deal with broken link
			continue
		}
		if new_path.is_dir() {
			// If recusrive
			if args.recursive {
				mut rec_list := new_path.list(args)?
				all_list << rec_list
			}
		}
		// Check if tofound is a part of the path
		if args.tofind != '' && !p.contains(args.tofind) {
			continue
		}
		all_list << new_path
	}
	return all_list
}

// find dir underneith path,
pub fn (mut path Path) dir_list(args ListArgs) ?[]Path {
	list_all := path.list(args)?
	mut list_dirs := list_all.filter(it.cat == Category.dir)
	return list_dirs
}

// find file underneith path,
pub fn (mut path Path) file_list(args ListArgs) ?[]Path {
	list_all := path.list(args)?
	mut list_files := list_all.filter(it.cat == Category.file)
	return list_files
}

// find links (don't follow)
pub fn (mut path Path) link_list(args ListArgs) ?[]Path {
	list_all := path.list(args)?
	mut list_links := list_all.filter(it.cat in [Category.linkdir, Category.linkfile])
	return list_links
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
pub fn path_relative(source_ string, linkpath_ string) string {
	mut source := os.abs_path(source_)
	mut linkpath := os.abs_path(linkpath_)
	// now both start with /
	common := find_common_ancestor([source, linkpath])

	// if source is common, returns source
	if source_.len <= common.len + 1 {
		path := linkpath_.trim_string_left(source_)
		if path.starts_with('/') {
			return path[1..]
		} else {
			return path
		}
	}

	mut source_short := source[(common.len + 1)..]
	if source_.count('/') == 1 {
		source_short = source[(common.len)..]
	}

	mut linkpath_short := linkpath[(common.len + 1)..]
	if linkpath_.count('/') == 1 {
		linkpath_short = linkpath[(common.len)..]
	}

	source_count := source_short.count('/')
	// link_count := linkpath_short.count('/')
	mut dest := ''
	if source_count > 0 {
		go_up := ['../'].repeat(source_count).join('')
		dest = '$go_up$linkpath_short'
	} else {
		if source_short != linkpath_short {
			dest = './' + linkpath_short
		} else {
			dest = linkpath_short
		}
	}

	println('source:$source linkpath:$linkpath')
	println('source_short:$source_short linkpath_short:$linkpath_short')
	println('path_relative $dest')

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

// create symlink on dest (which is path wich is non existing, the to be created link)
// return Path of the symlink
// if delete_exists then it will remove the destination if it exists
// the symlink is always done relative to each other
pub fn (mut path Path) link(dest string, delete_exists bool) ?Path {
	if !path.exists() {
		return error('cannot link because source $path.path does not exist')
	}
	if !(path.cat == .file || path.cat == .dir) {
		return error('cannot link because source $path.path can only be dir or file')
	}
	if os.exists(dest) {
		if delete_exists {
			os.rm(dest)?
		} else {
			return error('cannot link $path.path to $dest, because dest exists.')
		}
	}
	// create dir if it would not exist yet
	dest_dir := os.dir(path.path)
	if !os.exists(dest_dir) {
		os.mkdir_all(dest_dir)?
	}
	// calculate relative link between source and dest
	println("debugz: $path \n$dest")
	dest_path := path_relative(path.path, dest)
	os.symlink(path.path, dest_path)?
	match path.cat {
		.dir, .linkdir {
			return Path{
				path: dest_path
				cat: Category.linkdir
				exist: .yes
			}
		}
		.file, .linkfile {
			return Path{
				path: dest_path
				cat: Category.linkfile
				exist: .yes
			}
		}
		.unknown {
			return error('Path cannot be unknown type')
		}
	}
}

// will make sure that the link goes from file with largest path to smalles
// good to make sure we have links always done in same way
pub fn (mut path Path) relink() ? {
	if !path.is_link() {
		return
	}

	link_abs_path := path.absolute() // symlink not followed
	link_real_path := path.realpath() // this is with the symlink resolved
	if compare_strings(link_abs_path, link_real_path) >= 0 {
		// means the shortest path is the target (or if same size its sorted and the first)
		return
	}
	// need to switch link with the real content
	path.unlink()? // make sure both are files now (the link is the file)
	path.link(link_real_path, true)? // re-link
	path.check()

	// TODO: in test script
}

// resolve link to the real content
// copy the target of the link to the link
pub fn (mut path Path) unlink() ? {
	if !path.is_link() {
		// nothing to do because not link, will not giver error
		return
	}
	link_abs_path := path.absolute()
	link_real_path := path.realpath() // this is with the symlink resolved
	mut link_path := get(link_real_path)
	$if debug {
		println(" - copy source file:'$link_real_path' of link to link loc:'$link_abs_path'")
	}
	mut destpath := get(link_abs_path + '.temp') // lets first copy to the .temp location
	link_path.copy(mut destpath)? // copy to the temp location
	path.delete()? // remove the file or dir which is link
	destpath.rename(path.name())? // rename to the new path
	path.path = destpath.path // put path back
	path.check()
	// TODO: in test script
}

// return path object for the link this one is pointing too
pub fn (mut path Path) readlink() ?Path {
	println('path: $path')
	if path.is_link() {
		println('path2: $path')
		cmd := 'readlink $path.path'
		res := os.execute(cmd)
		if res.exit_code > 0 {
			return error('cannot define result for link of $path \n$error')
		}
		return get(res.output.trim_space())
	} else {
		return error('can only read link info when the path is a filelink or dirlink. $path')
	}
}

// return path object which is the result of the link
pub fn (mut path Path) getlink() ?Path {
	if path.is_link() {
		return get(path.realpath())
	} else {
		return error('can only get link when the path is a filelink or dirlink. $path')
	}
}
