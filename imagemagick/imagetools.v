module imagemagick

// import os
// import pathlib
// import process

pub fn (mut images Images) downsize(sourcedir string, backupdir string) ? {
	for mut image in images.images {
		image.downsize(sourcedir, backupdir)?
	}
}
