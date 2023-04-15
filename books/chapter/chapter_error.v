module chapter
import freeflowuniverse.crystallib.pathlib { Path }

pub enum ChapterErrorCat {
	unknown
	image_double
	file_double
	file_not_found
	image_not_found
	page_double
	page_not_found
	sidebar
}

pub struct ChapterErrorArgs {
pub:
	path Path
	msg  string
	cat  ChapterErrorCat
}

pub struct ChapterError {
pub mut:
	path Path
	msg  string
	cat  ChapterErrorCat
}

pub fn (mut chapter Chapter) error(args ChapterErrorArgs) {
	chapter.errors << ChapterError{
		path: args.path
		msg: args.msg
		cat: args.cat
	}
}