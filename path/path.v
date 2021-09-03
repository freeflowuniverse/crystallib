module path

import os

pub struct Path {
pub mut:
	path string
	exists PathExists
	cat Category
}

pub enum Category{
	unknown
	file
	dir
	linkdir
	linkfile
}

pub enum PathExists{
	unknown
	yes
	no
}


// Files
//will create file obj, check if it exists
pub fn file_new(path string)? Path {
	if os.exists(path){
		if ! os.is_file(path){
			return error("cannot create new file obj, because file existed and was not file type. $path")
		}
		return Path{path:path, cat:Category.file, exists:PathExists.yes}
	}else{
		return Path{path:path, cat:Category.file, exists:PathExists.no}
	}
}


//will create a new empty file
//CAREFULL: if it exists, will delete
fn file_new_empty(path string)? Path {
	if ! os.exists(path){
		//Check if the parent directory exists, if not create one
		dir_path := os.dir(path) // get directory path
		os.mkdir_all(dir_path)? // Make sure that all the needed paths created
	}
	os.write_file(path,"")? // Make file empty even if exists
	return Path{path:path, cat:Category.file, exists:PathExists.yes}
}

//will create file obj, check if it exists, if not will give error
fn file_new_exists(path string)? Path {
	if ! os.exists(path){
		return error("cannot find file: $path")
	}
	if ! os.is_file(path){
		return error("cannot create new file obj, because file existed and was not file type. $path")
	}
	return Path{path:path, cat:Category.file, exists:PathExists.yes}
}

// Directories
//will create dir obj, check if it exists
fn dir_new(path string)? Path {
	if os.exists(path){
		if ! os.is_dir(path){
			return error("cannot create new dir obj, because dir existed and was not dir type. $path")
		}	
		return Path{path:path, cat:Category.dir, exists:PathExists.yes}
	}else{
		return Path{path:path, cat:Category.dir, exists:PathExists.no}
	}
}

//will create a new empty dir
//CAREFULL: if it exists, will delete
fn dir_new_empty(path string)? Path {
	if os.exists(path) && ! os.is_dir_empty(path){
		os.rmdir_all(path) ?// delete dir with its content
	}
	os.mkdir_all(path)? // create dir and make sure it is empty dir
	return Path{path:path, cat:Category.dir, exists:PathExists.yes}
}

//will create dir obj, check if it exists, if not will give error
fn dir_new_exists(path string)? Path {
	if ! os.exists(path){
		return error("cannot find dir: $path")
	}
	if ! os.is_dir(path){
		return error("cannot create new dir obj, because dir existed and was not dir type. $path")
	}
	return Path{path:path, cat:Category.dir, exists:PathExists.yes}
}

// LinkFiles 
// Note: is_link function works with symlinks only
//will create linkfile obj, check if it exists
fn linkfile_new(path string)? Path {
	if os.exists(path){
		if ! (os.is_link(path) && os.is_file(path)){
			return error("cannot create new linkfile obj, because it is existed and was not linkfile type. $path")
		}
		return Path{path:path, cat:Category.linkfile, exists:PathExists.yes}
	}else{
		return Path{path:path, cat:Category.linkfile, exists:PathExists.no}
	}
}


//will create linkfile obj, check if it exists, if not will give error
fn linkfile_new_exists(path string)? Path {
	if ! os.exists(path){
		return error("cannot find linkfile: $path")
	}
	if ! (os.is_link(path) && os.is_file(path)){
		return error("cannot create new linkfile obj, because it is existed and was not linkfile type. $path")
	}
	return Path{path:path, cat:Category.linkfile, exists:PathExists.yes}
}

// LinkDirs, Note: is_link function works with symlinks only
//will create linkdir obj, check if it exists
fn linkdir_new(path string)? Path {
	if os.exists(path){
		if ! (os.is_link(path) && os.is_dir(path)){
			return error("cannot create new linkdir obj, because it is existed and was not linkdir type. $path")
		}
		return Path{path:path, cat:Category.linkdir, exists:PathExists.yes}
	}else{
		return Path{path:path, cat:Category.linkdir, exists:PathExists.no}
	}
}

//will create file obj, check if it exists, if not will give error
fn linkdir_new_exists(path string)? Path {
	if ! os.exists(path){
		return error("cannot find linkdir: $path")
	}
	if ! (os.is_link(path) && os.is_dir(path)){
		return error("cannot create new linkdir obj, because it is existed and was not linkdir type. $path")
	}
	return Path{path:path, cat:Category.linkdir, exists:PathExists.yes}
}

//check if path obj exists, is file, link, dir, ...
pub fn get(path string)? Path {
	if ! os.exists(path){
		return error("File not exists")
	}
	if os.is_file(path){
		if os.is_link(path){
			return Path{path:path, cat:Category.linkfile, exists:PathExists.yes}
		}else{
			return Path{path:path, cat:Category.file, exists:PathExists.yes}
		}
	}
	if os.is_dir(path){
		if os.is_link(path){
			return Path{path:path, cat:Category.linkdir, exists:PathExists.yes}
		}else{
			return Path{path:path, cat:Category.dir, exists:PathExists.yes}
		}
	}
}

/////////

//check path exists
pub fn (mut path Path) exists() bool {
	if path.exists == PathExists.yes{
		return true
	}
	if path.exists == PathExists.no{
		return false
	}
	if os.exists(path.path){
		path.exists = PathExists.yes
		return true
	}else{
		path.exists = PathExists.no
		return false
	}
	return false
}

//absolute path
pub fn (path Path) path_absolute() string {
	//Check if the link is read --> Working with links but return the origin path
	return os.real_path(path.path)
}

//find parent of path
pub fn (path Path) parent() ?Path {
	mut p := path.path_absolute()
	parent := os.dir(p) // get parent directory
	if parent == "."{
		return error("no parent for path $path")
	}else if parent == "" {
		return Path{path:"/",cat:Category.dir, exists:PathExists.yes}
	}
	return Path{path:parent,cat:Category.dir, exists:PathExists.yes}
	// splitted := path.path_absolute().split("/")
	// if len(splitted)==0{
	// 	return error("no parent for path $path")
	// }
	// path2:="/".join(splitted[0..len(splitted)-1])
	// return Path{path:path2,cat:Category.dir, exists:PathExists.yes}
}


//walk upwards starting from path untill dir or file tofind is found
//works recursive
pub fn (path Path) parent_find(tofind string)  ?Path {
	if os.exists(os.join_path(path.path,tofind)) {
		return path
	}
	mut path2 := path.parent()?
	return path2.parent_find(tofind)
}


//delete
pub fn (mut path Path) delete()?{
	if ! os.exists(path.path){
		return error("Can't delete unfound file/dir")
	}
	match path.cat {
		.file, .linkfile, .linkdir {
			os.rm(path.path) ?
		}
		.dir {
			os.rmdir_all(path.path) ?
		}
		.unknown {
			return error("Path cannot be unknown type")
		}		
	}
	path.exists = PathExists.no
}

//find dir underneith path, if exists return True
pub fn (mut path Path) dir_exists(tofind string) bool{
	if path.cat != Category.dir {
		return false
	}
	mut files := os.ls(path.path) or {[]string{}}
	if tofind in files {
		dir_path := os.join_path(path.path, tofind)
		if os.is_dir(dir_path){
			return true
		}
	}
	return false
}

//find dir underneith path, return as Path
pub fn (mut path Path) dir_find(tofind string) ?Path{
	if path.dir_exists(tofind) {
		dir_path := os.join_path(path.path, tofind)
		return Path{path:dir_path,cat:Category.dir, exists:PathExists.yes}
	}
	return error("$tofind is not in $path.path")
}


//find file underneith path, if exists return True
pub fn (mut path Path) file_exists(tofind string)bool{
	if path.cat != Category.dir {
		return false
	}
	files := os.ls(path.path) or {[]string{}}
	if tofind in files {
		file_path := os.join_path(path.path, tofind)
		if os.is_file(file_path){
			return true
		}
	}
	return false
}

//find file underneith path, return as Path, can only be one
//tofind is part of file name
pub fn (mut path Path) file_find(tofind string)?Path{
	if path.file_exists(tofind) {
		file_path := os.join_path(path.path, tofind)
		return Path{path:file_path,cat:Category.file, exists:PathExists.yes}
	}
	return error("$tofind is not in $path.path")
}


//list all files & dirs, follow symlinks
//return as list of Paths
//param tofind: part of name (relative to path.path)
//param recursive: if recursive behaviour
pub fn (mut path Path) list(tofind string,recursive bool)?[]Path{
	if !(path.cat in [Category.dir, Category.linkdir]) {
		return error("Path must be dirctory or link to directory")
	}
	
	ls_result := os.ls(path.path) or {[]string{}}
	mut all_list := []Path{}
	for item in ls_result {
		mut new_path := Path{}
		p := os.join_path(path.path, item)
		// Check for dir and linkdir
		if os.is_dir(p){
			if os.is_link(p){
				new_path.cat = Category.linkdir
			}else{
				new_path.cat = Category.dir
			}
			// If recusrive
			if recursive {
				mut rec_path := Path{path:p, cat:new_path.cat, exists:PathExists.yes}
				mut rec_list := rec_path.list(tofind, recursive) ?
				all_list << rec_list
			}
		}
		// Check if linkfile
		else if os.is_file(p){
			if os.is_link(p){
				new_path.cat = Category.linkfile
			}else{
				new_path.cat = Category.file
			}
		}
		// Check if tofound is a part of the path
		if tofind != "" && ! p.contains(tofind){
			continue
		}
		new_path.path = p
		new_path.exists = PathExists.yes
		all_list << new_path
	}
	return all_list
}

//find dir underneith path,
pub fn (mut path Path) dir_list(tofind string,recursive bool)?[]Path{
	list_all := path.list(tofind, recursive)?
	mut list_dirs := list_all.filter(it.cat == Category.dir)
	return list_dirs
}

//find file underneith path,
pub fn (mut path Path) file_list(tofind string,recursive bool)?[]Path{
	list_all := path.list(tofind, recursive)?
	mut list_files := list_all.filter(it.cat == Category.file)
	return list_files
}

//find links (don't follow)
pub fn (mut path Path) link_list(tofind string)?[]Path{
	list_all := path.list(tofind, false)?
	mut list_links := list_all.filter(it.cat in [Category.linkdir, Category.linkfile])
	return list_links
}

//write content to the file, check is file
pub fn (mut path Path) write(content string)?{
	if path.cat != Category.file{
		return error("Path must be a file")
	}
	if ! os.exists(path.path){
		os.mkdir_all(path.path) ?
	}
	os.write_file(path.path, content) ?
}

//read content from file
pub fn (mut path Path) read()?string{
	match path.cat {
		.file, .linkfile {
			p := path.path_absolute()
			if ! os.exists(p) {
				return error("File is not exist, $p is a wrong path")
			}
			return os.read_file(p)
		}
		else{
			return error("Path is not a file")
		}
	}
}

//copy file,dir is always recursive
//dest needs to be a directory or file
//need to check than only valid items can be done
//return Path of the destination file or dir
pub fn (mut path Path) copy(dest Path)?Path{
	if ! (path.cat in [.file, .dir] && dest.cat in [.file, .dir]) {
		return error("Source or Destination path is not file or directory")
	}
	if path.cat == .dir && dest.cat == .file {
		return error("Can't copy directory to file")
	}
	os.cp_all(path.path, dest.path, true) ?// Always overwite if needed
	if path.cat == .file && dest.cat == .dir {
		// In case src is a file and dest is dir, we need to join the file name to the dest file
		file_name := os.base(path.path)
		dest_path := os.join_path(dest.path, file_name)
		return Path{path:dest_path,cat:Category.file, exists:PathExists.yes}
	}
	return Path{path:dest.path, cat:dest.cat, exists:PathExists.yes}
}

//create symlink on dest (which is Path wich is non existing)
//return Path of the symlink
pub fn (mut path Path) link(dest Path)?Path{
	os.symlink(path.path, dest.path) ?
	match path.cat{
		.dir, .linkdir {
			return Path{path:dest.path,cat:Category.linkdir, exists:PathExists.yes}
		}
		.file, .linkfile{
			return Path{path:dest.path,cat:Category.linkfile, exists:PathExists.yes}
		}
		.unknown {
			return error("Path cannot be unknown type")
		}		
	}
}



//TODO: create a good set of tests
