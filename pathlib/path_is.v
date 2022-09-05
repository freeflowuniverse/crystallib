module pathlib

const image_exts = ['jpg', 'jpeg', 'png', 'gif', 'svg']
const image_exts_basic = ['jpg', 'jpeg', 'png']

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
	e := path.extension().to_lower()
	// println("is image: $e")
	return pathlib.image_exts.contains(e)
}

pub fn (path Path) is_image_jpg_png() bool {
	e := path.extension().to_lower()
	// println("is image: $e")
	return pathlib.image_exts_basic.contains(e)
}

