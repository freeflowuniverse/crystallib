module publisher_core

import os

pub enum FileStatus {
	unknown
	ok
	error
	deleted
}

pub struct File {
	id      int [skip]
	site_id int [skip]
pub mut:
	name   string
	path   string
	state  FileStatus
	usedby []int // names of pages which use this file
}

pub fn (file File) site_get(mut publisher &Publisher) ?&Site {
	return publisher.site_get_by_id(file.site_id)
}

pub fn (file File) path_relative_get(mut publisher &Publisher) string {
	if file.path == '' {
		panic('file path should never be empty, is bug')
	}
	return file.path
}

pub fn (file File) path_get(mut publisher &Publisher) string {
	if file.site_id > publisher.sites.len {
		panic('cannot find site: $file.site_id, not enough elements in list.')
	}
	if file.state == FileStatus.deleted {
		panic('file should not be used is deleted\n$file')
	}
	if file.path == '' {
		panic('file path should never be empty, is bug. For file\n$file')
	}
	site_path := publisher.sites[file.site_id].path
	return os.join_path(site_path, file.path)
}

// get the name of the file with or without site prefix, depending if file is in the site
pub fn (file File) name_get(mut publisher &Publisher, site_id int) string {
	site := file.site_get(mut publisher) or { panic(err) }
	if site.id == site_id {
		return file.name
	} else {
		return '$site.name:$file.name'
	}
}
