module publisher
import path as pathlib
import os
import freeflowuniverse.crystallib.path

pub enum FileStatus {
	unknown
	ok
	error
	deleted
}

[heap]
pub struct File {
	name string 		//received a name fix
	dirpath string		//path in site (without name)
	path Path
	site &Site [str: skip] //pointer to site	
pub mut:
	// relative path inside the site
	pathrel string
	state   FileStatus [skip]
	usedby  []int // names of pages which use this file
	id      int        [skip]
}

//add file to the site, as has been found there
pub (mut site Site) file_new(fpath string) ?File {
	mut p := pathlib.get_file(fpath)? //makes sure we have the right path
	if ! p.path.exists(){
		return error("cannot find page: $page for path: ${page.path}")
	}
	p.namefix()? //make sure its all lower case and name is proper

	mut p := pathlib.get_file(fpath)? //makes sure we have the right path
	if ! p.path.exists(){
		return error("cannot find page: $page for path: ${page.path}")
	}
	p.namefix()? //make sure its all lower case and name is proper
	mut p: = File{
		name: p.name()
		dirpath: p.path_relative(site.path.path))
		path: p
		site: &site
	}

	if file.site_id > publisher.sites.len {
		return error('cannot find site: $file.site_id, not enough elements in list.\n$file')
	}
	if file.pathrel == '' {
		return error('file path should never be empty, is bug. For file\n$file')
	}
	return file
}

//get relative path with filename in the site
pub fn (page Page) path_relative() string {
	return os.join_path(page.dirpath,page.name)
}




// get the name of the file with or without site prefix, depending if file is in the site
pub fn (file File) name_with_site( site_id int) ?string {
	site := file.site_get(mut publisher)?
	if site.id == site_id {
		return file.name(mut publisher)
	} else {
		return '$site.name:${file.name(mut publisher)}'
	}
}

// returns name without extension and _ from image
// returns name with extension for normal file
// all is lower case & normalized
pub fn (file File) name_fixed() ?string {
	mut patho := file.path_object_get(mut publisher)?
	return publisher.path_get_name_fix(patho.path)
}
