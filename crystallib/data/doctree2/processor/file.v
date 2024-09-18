module processor

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctreemodel
import os


//process the file, get it to the destination
//path is location of the source
pub fn file_process(mut collection doctreemodel.Collection, path string) {
	mut myfile:=pathlib.file_get(path)!
	mut ftype := doctreemodel.FileType.file
	if myfile.is_image() {
		ftype = .image
	}

	name := file.path.name_fix_no_ext()
	ext := file.path.path.all_after_last('.').to_lower()

	dest :=  "${collection.path}/img/${name}.${ext}"

	myfile.copy(dest:, rsync: false) or {
		return error('Could not copy file: ${file.path.path} to ${dest} .\n${err}\n${file}')
	}

	



}


