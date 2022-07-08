module publisher_core

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
	site_id int
pub mut:
	// relative path inside the site
	pathrel string
	state   FileStatus [skip]
	usedby  []int // names of pages which use this file
	id      int        [skip]
}

fn file_new(mut patho path.Path, site Site, mut publisher Publisher) ?File {
	if !patho.exists() {
		return error('Cannot add file ')
	}
	pathrelative := patho.path_relative(site.path)
	mut file := File{
		site_id: site.id
		pathrel: pathrelative
	}
	if file.site_id > publisher.sites.len {
		return error('cannot find site: $file.site_id, not enough elements in list.\n$file')
	}
	if file.pathrel == '' {
		return error('file path should never be empty, is bug. For file\n$file')
	}
	return file
}

fn file_add(mut file File, mut publisher Publisher) &File {
	if publisher.files.len == 0 {
		publisher.files = []File{}
	}
	file.id = publisher.files.len
	publisher.files << file
	return &publisher.files[file.id]
}

pub fn (file File) site_get(mut publisher Publisher) ?&Site {
	return publisher.site_get_by_id(file.site_id)
}

pub fn (file File) site_path_get(mut publisher Publisher) ?string {
	site := file.site_get(mut publisher)?
	return site.path
}

pub fn (file File) site_name_get(mut publisher Publisher) ?string {
	site := file.site_get(mut publisher)?
	return site.name
}

pub fn (file File) path_get(mut publisher Publisher) ?string {
	sitepath := file.site_path_get(mut publisher)?
	return os.join_path(sitepath, file.pathrel)
}

pub fn (file File) path_object_get(mut publisher Publisher) ?path.Path {
	p := file.path_get(mut publisher)?
	return path.get_file(p, false)
}

pub fn (file File) name(mut publisher Publisher) string {
	return file.pathrel.all_after_last('/')
}

// get the name of the file with or without site prefix, depending if file is in the site
pub fn (file File) name_with_site(mut publisher Publisher, site_id int) ?string {
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
pub fn (file File) name_fixed(mut publisher Publisher) ?string {
	mut patho := file.path_object_get(mut publisher)?
	return publisher.path_get_name_fix(patho.path)
}
