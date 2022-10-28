module pathlib

// join parts to a path and return path, returns a new path
pub fn (mut p Path) join(parts ...string) ?Path {
	mut p2 := Path{
		path: p.path
	}
	//TODO Add tests
	p2.check()

	if !p2.is_dir() {
		return error('can only extend dir, $p2.path')
	}
	for part in parts {
		if part.contains('~') {
			return error('cannot extend part $part if ~ in')
		}
		part2 := part.trim(' ')
		p2.path += '/' + part2
	}
	p2.path = p2.path.replace('//', '/')
	p2.check()
	return p2
}

// extend the path, path stays same, no return
// if dir, needs to stay dir
// anything else fails
pub fn (mut path Path) extend(parts ...string) ? {
	if !path.is_dir() {
		return error('can only extend dir, $path')
	}
	for part in parts {
		if part.contains('~') {
			return error('cannot extend part to $part if ~ in')
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

// pub fn (path Path) extend_dir(relpath string) ? {

// 	relpath2 = relpath2.replace("\\","/")

// 	if path.cat != Category.dir{
// 		return error("cannot only extend a dir, not a file or a link. $path")
// 	}
// 	return dir_new("$path/relpath2")
// }

// pub fn (path Path) extend_file_exists(relpath string) ?Path {

// 	mut relpath2 := relpath.trim(" ")

// 	relpath2 = relpath2.replace("\\","/")

// 	if path.cat != Category.dir{
// 		return error("cannot only extend a dir, not a file or a link. $path")
// 	}
// 	return file_new_exists("$path/relpath2")
// }

// pub fn (path Path) extend_exists(relpath string) ?Path {

// 	p2 := path.extend(relpath)?
// 	if ! p2.exists(){
// 		return error("cannot extend $path with $relpath, directory does not exist")
// 	}
// 	return p2
// }
