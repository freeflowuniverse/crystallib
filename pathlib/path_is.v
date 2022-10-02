module pathlib

const image_exts = ['jpg', 'jpeg', 'png', 'gif', 'svg']

const image_exts_basic = ['jpg', 'jpeg', 'png']

pub fn (path Path) is_dir() bool {
	if path.cat == Category.unknown {
		panic("did not check path yet")
	}
	return path.cat == Category.dir || path.cat == Category.linkdir
}

pub fn (path Path) is_dir_link() bool {
	if path.cat == .unknown {
		panic("did not check path yet")
	}
	return path.cat == Category.linkdir
}

pub fn (path Path) is_file() bool {
	if path.cat == .unknown {
		panic("did not check path yet")
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

pub fn (path Path) is_link() bool {
	if path.cat == .unknown {
		// println(path)
		panic("did not check path yet.")
	}
	return path.cat == Category.linkfile || path.cat == Category.linkdir
}
