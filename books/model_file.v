module books
import path as pathlib

pub enum FileStatus {
	unknown
	ok
	error
}


[heap]
pub struct File {	
pub:
	name string 		//received a name fix
	site &Site [str: skip] //pointer to site
pub mut:
	path pathlib.Path
	pathrel string
	state           FileStatus
	pages_linked []&Page [str: skip] //pointer to pages which use this file
}

//only way how to get to a new file
pub fn (mut site Site) file_new(fpath string)?File {
	mut p := pathlib.get_file(fpath,false)? //makes sure we have the right path
	if ! p.exists(){
		return error("cannot find file for path in site: ${fpath}")
	}
	p.namefix()? //make sure its all lower case and name is proper
	mut ff := File{
		name: p.name()
		path: p
		pathrel: p.path_relative(site.path.path)
		site: &site
	}
	return ff
}

