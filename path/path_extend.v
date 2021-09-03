module path

//join parts to a path and return path, returns a new path
pub fn (path Path) join(parts ...string) Path {
	mut p2 := Path{
		path:path.path
		exists:false
		absolute:path.absolute

	}
	if ! p2.is_dir(){
		panic("can only extend dir, $p2.path")
	}
	for mut part in parts{
		if "~" in part{
			panic("cannot extend part to $path.path if ~ in")
		}
		part = part.trim(" ")
		p2.path += part
	}
	path.check()
	return path
}

//extend the path, path stays same, no return
//if dir, needs to stay dir
// anything else fails
pub fn (path Path) extend(parts ...string)? {
	if ! path.is_dir(){
		return error("can only extend dir, $path.path")
	}
	for mut part in parts{
		if "~" in part{
			return error("cannot extend part to $path.path if ~ in")
		}
		part = part.trim(" ")
		path.path += part
	}
	if path.exists(){
		if ! path.is_dir(){
			return error("can only extend dir if is dir again.")
		}
	}
	path.check()	
}

pub fn (path Path) extend_dir(relpath path.Path) ? {


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


