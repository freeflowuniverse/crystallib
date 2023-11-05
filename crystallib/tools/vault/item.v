module vault

import freeflowuniverse.crystallib.core.pathlib
import time

pub struct Item {
mut:
	shelve &Shelve [str: skip]
pub:
	sha256 string
	time   time.Time
	nr     u16
	name   string
}

// save the metadata for the backups
pub fn (i Item) meta() string {
	return '${i.sha256}|${i.nr}|${i.name}'
}

// get path object representing the vaulted item
fn (i Item) path() !pathlib.Path {
	pathstr := '${i.shelve.path.path}/.vault/${i.name_nr}'
	return pathlib.get_file(path: pathstr, create: true)
}

// content of the vaulted item
fn (i Item) content() !string {
	mut p := i.path()!
	return p.read()
}

// save the metadata for the backups
pub fn (i Item) sha256() !string {
	mut p := i.path()!
	return p.sha256()
}

// get the name of the item in the shelve
// if its the first one then its the original name
pub fn (i Item) name_nr() string {
	if i.nr == 0 {
		return i.name
	} else if i.name.contains('.') {
		nameext := i.name.all_after_last('.')
		name3 := i.name.all_before_last('.')
		return '${name3}.${i.nr}.${nameext}'
	} else {
		return '${i.name}.${i.nr}'
	}
}
