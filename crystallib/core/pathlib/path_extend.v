module pathlib

// join parts to a path and return path, returns a new path, create if needed
pub fn (mut p Path) extend_dir_create(parts ...string) !Path {
	mut out := p.path
	if !p.is_dir() {
		return error('Cannot only extend a dir.')
	}
	if p.exists() == false {
		return error("Cannot extend a dir if it doesn't exist")
	}
	for part in parts {
		if part.contains('~') {
			return error('cannot extend part ${part} if ~ in')
		}
		part2 := part.trim(' ')
		out += '/' + part2.trim('/')
	}
	out = out.replace('//', '/')
	mut p2 := get_dir(path:out, create:true)!
	return p2
}

// only works for a dir
pub fn (mut p Path) extend_file(name string) !Path {
	if !p.is_dir() {
		return error('Cannot only extend a dir.')
	}
	if p.exists() == false {
		return error("Cannot extend a dir if it doesn't exist")
	}

	mut out := p.path
	if name.contains('~') {
		return error('cannot extend dir if ~ in name: ${name}')
	}
	out += '/' + name.trim('/')
	out = out.replace('//', '/')
	mut p2 := get_file(path:out)!
	return p2
}

// extend the path, path stays same, no return
// if dir, needs to stay dir
// anything else fails
pub fn (mut path Path) extend(parts ...string) ! {
	if !path.is_dir() {
		return error('can only extend dir, ${path}')
	}
	for part in parts {
		if part.contains('~') {
			return error('cannot extend part to ${part} if ~ in')
		}
		part2 := part.trim(' ')
		path.path += '/' + part2
	}
	if path.exists() {
		if !path.is_dir() {
			return error('can only extend dir if is dir again.')
		}
	}
	path.path = path.path.replace('//', '/')
	path.check()
}

// pub fn (path Path) extend_dir(relpath string) ! {

// 	relpath2 = relpath2.replace("\\","/")

// 	if path.cat != Category.dir{
// 		return error("cannot only extend a dir, not a file or a link. $path")
// 	}
// 	return dir_new("$path/relpath2")
// }

// pub fn (path Path) extend_file_exists(relpath string) !Path {

// 	mut relpath2 := relpath.trim(" ")

// 	relpath2 = relpath2.replace("\\","/")

// 	if path.cat != Category.dir{
// 		return error("cannot only extend a dir, not a file or a link. $path")
// 	}
// 	return file_new_exists("$path/relpath2")
// }

// pub fn (path Path) extend_exists(relpath string) !Path {

// 	p2 := path.extend(relpath)!
// 	if ! p2.exists(){
// 		return error("cannot extend $path with $relpath, directory does not exist")
// 	}
// 	return p2
// }
