module planner

import freeflowuniverse.crystallib.core.texttools
import os

struct PlannerSiteConfig {
	name string
	id   int
}

struct PlannerSite {
	id int [skip]
pub mut:
	errors  []SiteError
	path    string
	name    string // is the shortname!!!
	files   map[string]int
	issues  map[string]int
	stories map[string]int
	state   SiteState
	config  PlannerSiteConfig
	planner &Planner
}

pub enum SiteErrorCategory {
	duplicatefile
	duplicatepage
	emptypage
	unknown
}

struct SiteError {
pub:
	path  string
	error string
	cat   SiteErrorCategory
}

pub enum SiteState {
	init
	ok
	error
	loaded
}

pub fn (mut site PlannerSite) error_ignore_check(name string) bool {
	// for mut item in site.config.error_ignore {
	// 	if texttools.name_fix(name) == texttools.name_fix(item) {
	// 		return true
	// 	}
	// }
	return false
}

// pub fn (site Site) file_get(name string) ?&File {
// 	mut namelower := texttools.name_fix(name)
// 	if namelower in site.files {
// 		file := site.planner.file_get_by_id(site.files[namelower]) ?
// 		return file
// 	}
// 	return error('cannot find file with name $name')
// }

// pub fn (site Site) file_exists(name string) bool {
// 	mut namelower := texttools.name_fix(name)
// 	return namelower in site.files
// }
