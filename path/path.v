module path

import os

pub struct Path {
pub mut:
	path path.Path
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


//check if path obj exists, is file, link, dir, ...
pub fn get(path path.Path)? Path {
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


// Files
//will create file obj, check if it exists
pub fn file_new(path path.Path)? Path {
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
fn file_new_empty(path path.Path)? Path {
	if ! os.exists(path){
		//Check if the parent directory exists, if not create one
		dir_path := os.dir(path) // get directory path
		os.mkdir_all(dir_path)? // Make sure that all the needed paths created
	}
	os.write_file(path,"")? // Make file empty even if exists
	return Path{path:path, cat:Category.file, exists:PathExists.yes}
}

//will create file obj, check if it exists, if not will give error
fn file_new_exists(path path.Path)? Path {
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
fn dir_new(path path.Path)? Path {
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
fn dir_new_empty(path path.Path)? Path {
	if os.exists(path) && ! os.is_dir_empty(path){
		os.rmdir_all(path) ?// delete dir with its content
	}
	os.mkdir_all(path)? // create dir and make sure it is empty dir
	return Path{path:path, cat:Category.dir, exists:PathExists.yes}
}

//will create dir obj, check if it exists, if not will give error
fn dir_new_exists(path path.Path)? Path {
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
fn linkfile_new(path path.Path)? Path {
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
fn linkfile_new_exists(path path.Path)? Path {
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
fn linkdir_new(path path.Path)? Path {
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
fn linkdir_new_exists(path path.Path)? Path {
	if ! os.exists(path){
		return error("cannot find linkdir: $path")
	}
	if ! (os.is_link(path) && os.is_dir(path)){
		return error("cannot create new linkdir obj, because it is existed and was not linkdir type. $path")
	}
	return Path{path:path, cat:Category.linkdir, exists:PathExists.yes}
}


