module path

import os
import texttools

// check path exists
pub fn (mut path Path) exists() bool {
	if path.exists == PathExists.yes {
		return true
	}
	if path.exists == PathExists.no {
		return false
	}
	if os.exists(path.path) {
		path.exists = PathExists.yes
		return true
	} else {
		path.exists = PathExists.no
		return false
	}
	return false
}

// absolute path
pub fn (path Path) absolute() {
	if path.absolute {
		return
	}
	mut p2 := Path{
		path: path.path
		exists: path.exists
		cat: path.cat
	}
	p2.path = p2.path_absolute()
	p2.absolute = true
}

// absolute path
pub fn (path Path) path_absolute() string {
	// Check if the link is read --> Working with links but return the origin path
	p2 := path.path.replace('~', os.home_dir())
	return os.real_path(p2)
}

// get relative path in relation to sourcepath
pub fn (path Path) path_relative(sourcepath string) string {
	path_abs := path.path_absolute()
	sourcepath_abs := Path{
		path: sourcepath
	}.path_absolute()
	if path_abs.starts_with(sourcepath_abs) {
		return path_abs[sourcepath_abs.len..]
	}
	return path_abs
}

// find parent of path
pub fn (path Path) parent() ?Path {
	mut p := path.path_absolute()
	parent := os.dir(p) // get parent directory
	if parent == '.' || parent == '/' {
		return error('no parent for path $path.path')
	} else if parent == '' {
		return Path{
			path: '/'
			cat: Category.dir
			exists: PathExists.yes
		}
	}
	return Path{
		path: parent
		cat: Category.dir
		exists: PathExists.yes
	}
}

pub fn (path Path) extension() string {
	return os.file_ext(path.path).trim('.')
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
	mut path2 := path.parent()?
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
		path.exists = PathExists.no
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
pub fn (mut path Path) dir_find(tofind string) ?Path {
	if path.dir_exists(tofind) {
		dir_path := os.join_path(path.path, tofind)
		return Path{
			path: dir_path
			cat: Category.dir
			exists: PathExists.yes
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

// find file underneith path, return as Path, can only be one
// tofind is part of file name
pub fn (mut path Path) file_find(tofind string) ?Path {
	if path.file_exists(tofind) {
		file_path := os.join_path(path.path, tofind)
		return Path{
			path: file_path
			cat: Category.file
			exists: PathExists.yes
		}
	}
	return error('$tofind is not in $path.path')
}

// list all files & dirs, follow symlinks
// return as list of Paths
// param tofind: part of name (relative to string)
// param recursive: if recursive behaviour
pub fn (mut path Path) list(tofind string, recursive bool) ?[]Path {
	if path.cat !in [Category.dir, Category.linkdir] {
		return error('Path must be dirctory or link to directory')
	}

	ls_result := os.ls(path.path) or { []string{} }
	mut all_list := []Path{}
	for item in ls_result {
		mut new_path := Path{}
		p := os.join_path(path.path, item)
		// Check for dir and linkdir
		if os.is_dir(p) {
			if os.is_link(p) {
				new_path.cat = Category.linkdir
			} else {
				new_path.cat = Category.dir
			}
			// If recusrive
			if recursive {
				mut rec_path := Path{
					path: p
					cat: new_path.cat
					exists: PathExists.yes
				}
				mut rec_list := rec_path.list(tofind, recursive)?
				all_list << rec_list
			}
		}
		// Check if linkfile
		else if os.is_file(p) {
			if os.is_link(p) {
				new_path.cat = Category.linkfile
			} else {
				new_path.cat = Category.file
			}
		}
		// Check if tofound is a part of the path
		if tofind != '' && !p.contains(tofind) {
			continue
		}
		new_path.path = p
		new_path.exists = PathExists.yes
		all_list << new_path
	}
	return all_list
}

// find dir underneith path,
pub fn (mut path Path) dir_list(tofind string, recursive bool) ?[]Path {
	list_all := path.list(tofind, recursive)?
	mut list_dirs := list_all.filter(it.cat == Category.dir)
	return list_dirs
}

// find file underneith path,
pub fn (mut path Path) file_list(tofind string, recursive bool) ?[]Path {
	list_all := path.list(tofind, recursive)?
	mut list_files := list_all.filter(it.cat == Category.file)
	return list_files
}

// find links (don't follow)
pub fn (mut path Path) link_list(tofind string) ?[]Path {
	list_all := path.list(tofind, false)?
	mut list_links := list_all.filter(it.cat in [Category.linkdir, Category.linkfile])
	return list_links
}

// write content to the file, check is file
pub fn (mut path Path) write(content string) ? {
	if path.cat != Category.file {
		return error('Path must be a file')
	}
	if !os.exists(path.path) {
		os.mkdir_all(path.path)?
	}
	os.write_file(path.path, content)?
}

// read content from file
pub fn (mut path Path) read() ?string {
	match path.cat {
		.file, .linkfile {
			p := path.path_absolute()
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
			exists: PathExists.yes
		}
	}
	return Path{
		path: dest.path
		cat: dest.cat
		exists: PathExists.yes
	}
}

// create symlink on dest (which is Path wich is non existing)
// return Path of the symlink
pub fn (mut path Path) link(mut dest Path) ?Path {
	if dest.exists() {
		return error('cannot link $path.path to $dest.path, because dest exists.')
	}
	os.symlink(path.path, dest.path)?
	match path.cat {
		.dir, .linkdir {
			return Path{
				path: dest.path
				cat: Category.linkdir
				exists: PathExists.yes
			}
		}
		.file, .linkfile {
			return Path{
				path: dest.path
				cat: Category.linkfile
				exists: PathExists.yes
			}
		}
		.unknown {
			return error('Path cannot be unknown type')
		}
	}
}

// start from existing name and look for name_$nr.$ext, nr need to be unique, ideal for backups
pub fn (mut path Path) backup_name_find(source string, dest string) ?Path {
	if !path.exists() {
		return path
	}
	size := path.size()

	mut path_str := ''
	mut path_found := Path{}
	mut rel := ''
	if source != '' {
		path_abs := path.path_absolute()
		mut source_path := Path{
			path: source
		}.path_absolute()
		if path_abs.starts_with(source_path) {
			rel = os.dir(path_abs.substr(source_path.len + 1, path_abs.len)) + '/'
		}
	}
	os.mkdir_all('$dest/$rel')?
	for i in 0 .. 20 {
		if i == 0 {
			path_str = '$dest/$rel${path.name_no_ext()}.$path.extension()'
		} else {
			path_str = '$dest/$rel${path.name_no_ext()}_${i}.$path.extension()'
		}
		path_found = Path{
			path: path_str
		}
		if !path_found.exists() {
			return path_found
		}
		if size > 0 {
			if path_found.size() == size {
				// means we found the last one which is same as the one we are trying to backup
				return path_found
			}
		}
	}
	return error('cannot find path for backup, last one was: $path_found.path')
}
