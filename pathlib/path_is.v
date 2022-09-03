module pathlib

const image_exts = ['jpg', 'jpeg', 'png', 'gif', 'svg']

pub fn (mut path Path) is_dir() bool {
	if path.cat == Category.unknown {
		path.check()
	}
	return path.cat == Category.dir || path.cat == Category.linkdir
}

pub fn (mut path Path) is_file() bool {
	if path.cat == Category.unknown {
		path.check()
	}
	return path.cat == Category.file
}

pub fn (path Path) is_image() bool {
	// println(path.extension())
	return path.extension().to_lower() in pathlib.image_exts
}
