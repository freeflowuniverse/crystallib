module pathlib

pub fn (mut path Path) is_dir() bool {
	if path.cat == Category.unknown {
		path.check()
	}
	return path.cat == Category.dir
}

pub fn (mut path Path) is_file() bool {
	if path.cat == Category.unknown {
		path.check()
	}
	return path.cat == Category.file
}

pub fn (path Path) is_image() bool {
	// println(path.extension())
	return ['png', 'jpg', 'jpeg'].contains(path.extension().to_lower())
}
