module path

pub fn (mut path Path) is_dir() bool {
	return path.cat== Category.dir
}

pub fn (mut path Path) is_file() bool {
	return path.cat == Category.file
}
