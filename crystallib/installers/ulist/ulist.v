module ulist

// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.develop.gittools

// U stands for Upload
pub struct UList {
pub mut:
	root  string // common base for all UFiles
	items []UFile
}

pub struct UFile {
pub mut:
	path  string
	alias string // if other name used for upload, otherwise is the filename
	cat   UCat
}

pub enum UCat {
	file
	bin
	config
}
