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

//rename the file or directory
pub fn (mut path Path) rename(name string) ? {
	if name.contains("/"){
		return error("should only be a name no dir inside: '$name'")
	}
	mut dest := ""
	if path.path.contains("/"){
		before:=path.path.all_before_last("/")
		dest = before+"/"+name
	}else{
		dest = name
	}
	os.mv(path.path,dest)?
	path.path = dest
	path.check()
}



// get relative path in relation to sourcepath
// will not resolve symlinks
pub fn (mut path Path) path_relative(sourcepath string) string {
	path_abs := path.absolute()
	sourcepath_abs := get(sourcepath).absolute()
	if path_abs.starts_with(sourcepath_abs) {
		return path_abs[sourcepath_abs.len..]
	}
	return path_abs
}

// TODO: implement support for relative paths beginning with ../
pub fn path_relative(source_ string, dest_ string) ?string {
	mut source := source_.trim_right('/')
	mut dest := dest_.replace('//', '/').trim_right('/')
	// println("path relative: '$source' '$dest' ")
	if source !="" {
		if source.starts_with('/') && !dest.starts_with('/') {
			return error('if source starts with / then dest needs to start with / as well.\n - $source\n - $dest')
		}
		if !source.starts_with('/') && dest.starts_with('/') {
			return error('if source starts with / then dest needs to start with / as well\n - $source\n - $dest')
		}
	}
	if dest.starts_with(source) {
		return dest[source.len..]
	} else {
		msg := "Destination path is not in source directory: $source_ $dest_"
		return error(msg)
	}
}


// recursively finds the least common ancestor of array of paths
pub fn find_common_ancestor(paths []Path) ?string {
	paths2 := paths.map(it.realpath().trim_right("/")) //get the real path (symlinks... resolved)
	println(paths2)
	return find_common_ancestor2(paths2,"")
}

// recursively finds the least common ancestor of array of paths
// in a target directory.
// TODO: Maybe use absolute paths for flexibility
fn find_common_ancestor2(paths []string, target string) ?string {
	if paths.len < 2 {
		return error('Function expects at least two paths')
	}

	rel_paths := paths.map(path_relative(target, it)?.trim_left('/'))
	// if rel_paths.any(it.starts_with('../')) {
	// 	return error('Provided paths have no common ancestor in target directory')
	// }

	root := rel_paths[0].all_before('/')
	if rel_paths.any(!it.starts_with(root)) {
		return target
	} else {
		child_target := target + '/' + root
		return find_common_ancestor2(paths, child_target)
	}
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

//returns extension without .
pub fn (path Path) extension() string {
	return os.file_ext(path.path).trim('.')
}

//returns extension without and all lower case
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
			exist:.yes
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
		return error("is not a dir: $path.path")
	}
	files := os.ls(path.path) or { []string{} }
	if tofind in files {
		file_path := os.join_path(path.path, tofind)
		if os.is_file(file_path) {
			return get_file(file_path,false)
		}
	}	
	return error("")
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
			//to deal with broken link
			continue
		}
		if new_path.is_dir(){			
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

//recalc path between target & source
fn link_calculator_relative(mut source Path, mut linkpath Path) ?string{
	//make sure both is 
	mut source_dir:=source.realpath()
	mut linkpath_dir:=linkpath.realpath()
	//now both start with /
	if source_dir.len>linkpath_dir.len{
		println(source)
		println(linkpath)
		panic("calc relative, source should always be smaller")
	}
	common := find_common_ancestor([source,linkpath])?
	source_dir=source_dir[common.len..]
	linkpath_dir=linkpath_dir[common.len..]
	println(common)
	println(source_dir.count("/"))
	println(linkpath_dir.count("/"))
	if true{
		panic("s")
	}

	return ""
}

// create symlink on dest (which is path wich is non existing, the to be created link)
// return Path of the symlink
pub fn (mut path Path) link(mut dest Path) ?Path {
	if !path.exists() {
		return error("cannot link because source $path.path does not exist")
	}
	if !(path.cat == .file || path.cat == .dir){
		return error("cannot link because source $path.path can only be dir or file")
	}
	if dest.exists() {
		return error('cannot link $path.path to $dest.path, because dest exists.')
	}
	if ! os.exists(dest.path_dir()){
		os.mkdir_all(dest.path_dir())?
	}
	dest_path := link_calculator_relative(mut path,mut dest)?
	os.symlink(path.path, dest_path)?
	match path.cat {
		.dir, .linkdir {
			return Path{
				path: dest.path
				cat: Category.linkdir
				exist: .yes
			}
		}
		.file, .linkfile {
			return Path{
				path: dest.path
				cat: Category.linkfile
				exist: .yes
			}
		}
		.unknown {
			return error('Path cannot be unknown type')
		}
	}
}

//will make sure that the link goes from file with largest path to smalles
//good to make sure we have links always done in same way
pub fn (mut path Path) relink() ? {
	if ! path.is_link(){
		return
	}
	
	link_abs_path := path.absolute()
	if !link_abs_path.starts_with("/"){
		panic("bug, needs to be absolute")
	}
	link_real_path := path.realpath() //this is with the symlink resolved
	if path.path.contains("metaverse4"){
		println(link_real_path)
		println(link_abs_path)
		panic("fyghjfvmb")
	}
	if compare_strings(link_real_path,link_abs_path)>=0{
		//means the shortest path is the target
		return
	}
	//need to switch link with the real content
	mut linked:=get(link_real_path)
	path.unlink()? //make sure both are files now (the link is the file)
	linked.delete()?
	path.link(mut linked)? //re-link
	path.check()

}

//resolve link to the real content
//copy the target of the link to the link
pub fn (mut path Path) unlink() ? {
	if !path.is_link(){
		//nothing to do because not link, will not giver error
		return
	}
	link_abs_path := path.absolute()
	link_real_path := path.realpath() //this is with the symlink resolved
	mut link_path := get(link_real_path)
	$if debug{println(" - copy source file:'$link_real_path' of link to link loc:'$link_abs_path'")}
	mut destpath := get(link_abs_path+".temp") //lets first copy to the .temp location
	link_path.copy(mut destpath)? //copy to the temp location
	path.delete()? //remove the file or dir which is link
	destpath.rename(path.name())? //rename to the new path
	path.path = destpath.path //put path back
	path.check()
}

// return path object for the link this one is pointing too
pub fn (mut path Path) readlink() ?Path {
	if path.is_link() {
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

//return path object which is the result of the link
pub fn (mut path Path) getlink() ?Path {
	if path.is_link() {
		return get(path.realpath())
	} else {
		return error('can only get link when the path is a filelink or dirlink. $path')
	}
}
