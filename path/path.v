module path

import os

struct Path {
	path string
mut:
	exists i8
pub:
	cat Category
}

enum Category{
	file
	dir
	linkdir
	linkfile
}


//will create file obj, check if it exists
fn file_new(path string)? Path {
	if os.exists(path.path){
		if ! is_file(path.path){
			return error("cannot create new file obj, because file existed and was not file type. $path.path")
		}
		return Path{path:path, Category:Category.file, exists:1}
	}else{
		return Path{path:path, Category:Category.file, exists:2}
	}
}


//will create a new file
//CAREFULL: if it exists, will delete
//new file is empty
fn file_new_empty(path string)? Path {
	if ! os.exists(path){
		//TODO: need to check if the parent directory exists, if not create one --> Will use mkdir_all() to create any parent folder
		// Path not exist, create all needed parents
		parent_paths 
		os.mkdir_all(path)
		os.write_file(path,"")?
	}
	return Path{path:path, Category:Category.file, exists:1}
}

//will create file obj, check if it exists, if not will give error
fn file_new_exists(path string)? Path {
	if ! os.exists(path.path){
		return error("cannot find file: $path")
	}
	if ! is_file(path.path){
		return error("cannot create new file obj, because file existed and was not file type. $path.path")
	}
	return Path{path:path, Category:Category.file, exists:1}
}


//will create dir obj, check if it exists
fn dir_new(path string)? Path {
	if os.exists(path.path){
		if ! is_dir(path.path){
			return error("cannot create new dir obj, because dir existed and was not dir type. $path.path")
		}	
		return Path{path:path, Category:Category.dir, exists:1}	
	}else{
		return Path{path:path, Category:Category.dir, exists:2}
	}
}

//will create a new file
//CAREFULL: if it exists, will delete
//new file is empty
fn dir_new_empty(path string)? Path {
	if ! os.exists(path.path){
		os.mkdir_all(path)?
	}
	return Path{path:path, Category:Category.dir, exists:1}
}

//will create file obj, check if it exists, if not will give error
fn dir_new_exists(path string)? Path {
	if ! os.exists(path.path){
		return error("cannot find dir: $path")
	}
	if ! is_dir(path.path){
		return error("cannot create new dir obj, because dir existed and was not dir type. $path.path")
	}
	return Path{path:path, Category:Category.dir, exists:1}
}

//TODO: do same for link (dir & file)

//check if path obj exists, is file, link, dir, ...
fn (mut path Path) new(path string)? Path {
	if path.cat == PathCategory.unknown{
		if ! os.exists(path.path){
			path.cat = PathCategory.notexist
			return
		}
		if os.is_link(path.path){
			path.cat = PathCategory.link
			//TODO:read link
			//TODO:need to check is dir or file
			path.dest = "" //TODO
		}
	}
}

/////////

//check path exists
pub fn (mut path Path) exists() bool {
	if path.exists == 1{
		return true
	}
	if path.exists == 2{
		return false
	}	
	if os.exists(path.path){
		path.exists = 1
		return true
	}else{
		path.exists = 2
		return false
	}
	return false
}

//absolute path
pub fn (mut path Path) path_absolute() string {
	//todo, need to check if the link is read
	return os.real_path(path.path)
}

//find parent of path
pub fn (mut path Path) parent() ?Path {

	splitted := path.path_absolute().split("/")
	if len(splitted)==0{
		return error("no parent for path $path")
	}
	path2:="/".join(splitted[0..len(splitted)-1])
	return Path{path:path2,Category:Category.dir, exists:1}
}


//walk upwards starting from path untill dir or file tofind is found
//works recursive
pub fn (path Path) parent_find(tofind string)  ?string {
	if os.exists(os.join_path(path.path,tofind)) {
		return path
	}
	mut path2 := path.parent()?
	return path2.parent_find(tofind)?
}


//delete
pub fn (mut path Path) delete()?{
	//todo
}

//find dir underneith path, if exists return True
pub fn (mut path Path) dir_exists(tofind string)bool{
	//todo
}

//find dir underneith path, return as Path
pub fn (mut path Path) dir_find(tofind string)?Path{
	//todo
}


//find file underneith path, if exists return True
pub fn (mut path Path) file_exists(tofind string)bool{
	//todo
}

//find file underneith path, return as Path, can only be one
//tofind is part of file name
pub fn (mut path Path) file_find(tofind string)?Path{
	//todo
}


//list all files & dirs, follow symlinks
//return as list of Paths
//param tofind: part of name (relative to path.path)
//param recursive: if recursive behaviour
pub fn (mut path Path) list(tofind string,recursive bool)?[]Path{
	//todo
}

//find dir underneith path,
pub fn (mut path Path) dir_list(tofind string,recursive bool)?[]Path{
	//todo
}

//find file underneith path,
pub fn (mut path Path) file_list(tofind string,recursive bool)?[]Path{
	//todo
}

//find links (don't follow)
pub fn (mut path Path) link_list(tofind string,recursive bool)?[]Path{
	//todo
}

//write content to the file, check is file
pub fn (mut path Path) write(content string)?{
	//todo, create when not exist, create parent paths
}

//read content from file
pub fn (mut path Path) read()?string{
	//todo (error when it doesn't exist)
}

//copy file,dir is always recursive
//dest needs to be a directory or file
//need to check than only valid items can be done
//return Path of the destination file or dir
pub fn (mut path Path) copy(dest Path)?Path{
}

//create symlink on dest (which is Path wich is non existing)
//return Path of the symlink
pub fn (mut path Path) link(dest Path)?Path{
}



//TODO: create a good set of tests
