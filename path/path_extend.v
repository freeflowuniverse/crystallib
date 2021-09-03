module path



//absolute path
pub fn (path Path) extend_dir_exists(relpath path.Path) ?Path {
	mut p2 := path.extend_dir(relpath)?
	if ! p2.exists(){
		return error("cannot extend $path.path with $relpath, directory does not exist")
	}
	return p2
}

pub fn (path Path) extend_dir(relpath path.Path) ?Path {

	mut relpath2 := relpath.trim(" ")

	relpath2 = relpath2.replace("\\","/")

	if path.cat != Category.dir{
		return error("cannot only extend a dir, not a file or a link. $path.path")
	}
	return dir_new("$path.path/relpath2")
}


pub fn (path Path) extend_file_exists(relpath path.Path) ?Path {

	mut relpath2 := relpath.trim(" ")

	relpath2 = relpath2.replace("\\","/")

	if path.cat != Category.dir{
		return error("cannot only extend a dir, not a file or a link. $path.path")
	}
	return file_new_exists("$path.path/relpath2")
}


pub fn (path Path) extend_exists(relpath path.Path) ?Path {

	p2 := path.extend(relpath)?
	if ! p2.exists(){
		return error("cannot extend $path.path with $relpath, directory does not exist")
	}
	return p2
}




pub fn (path Path) extend(relpath path.Path) ?Path {

	mut relpath2 := relpath.trim(" ")

	relpath2 = relpath2.replace("\\","/")

	if path.cat != Category.dir{
		return error("cannot only extend a dir, not a file or a link. $path.path")
	}
	return get("$path.path/relpath2")
}


