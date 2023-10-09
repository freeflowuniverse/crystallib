module vault

import freeflowuniverse.crystallib.core.pathlib
import os
import crypto.sha256

pub struct Vault {
pub mut:
	name    string
	shelves []Shelve
	changed bool // if true it means that a change happened somewhere in the vault
}

// scan dir & subdirs, create a vault for it
pub fn do(path string) ?Vault {
	mut vault2 := get(path)?
	vault2.shelve()?
	return vault2
}

// get the vault object from existing dir
pub fn get(path string) ?Vault {
	mut p := pathlib.get_dir(path, false)?
	p.absolute()
	mut vault2 := scan(p.name(), mut p)?
	return vault2
}

// scan dir & subdirs, create a vault for it
// will not do the shelving let, will just create or load the vault attached to it
pub fn scan(name string, mut path pathlib.Path) ?Vault {
	mut vault := Vault{
		name: name
	}
	// now means we don't have the shelve yet, so need to create/load
	if !path.exists() {
		error('cannot find path, so cannot create shelve for ${path.path}')
	}
	if !path.is_dir() {
		return error('Can only create a shelve for a dir, now: ${path.path}')
	}
	vault.scan_recursive(mut path)?
	return vault
}

// walk over the dir's and find shelves and process them
fn (mut vault Vault) scan_recursive(mut path pathlib.Path) ? {
	vault.shelve_get(mut path)?
	mut llist := path.list(recursive: false)?
	for mut diritem in llist {
		if diritem.name().starts_with('.') || diritem.name().starts_with('_') {
			continue
		}
		if diritem.is_dir() {
			vault.scan_recursive(mut diritem)?
		}
	}
}

pub fn (mut vault Vault) shelve_get(mut path pathlib.Path) ?Shelve {
	// check if the shelve already exists, not the most efficient way for a big vault, but ok for now
	for shelve0 in vault.shelves {
		if shelve0.path.path == path.path {
			return shelve0
		}
	}

	// now means we don't have the shelve yet, so need to create/load
	if !path.exists() {
		error('cannot find path, so cannot create shelve for ${path.path}')
	}
	if !path.is_dir() {
		return error('Can only create a shelve for a dir, now: ${path.path}')
	}

	mut shelve := Shelve{
		path: path
	}
	shelve.load()?

	vault.shelves << shelve

	return shelve
}

// walk over the vault and re-shelve all dir's as owned by the vault
pub fn (mut vault Vault) shelve() ? {
	for mut shelve in vault.shelves {
		shelve.shelve()?
	}
}

// delete the vault remove all dirs
pub fn (mut vault Vault) delete() ? {
	for mut shelve in vault.shelves {
		shelve.delete()?
	}
}

// walk over the vault and re-shelve all dir's as owned by the vault
pub fn (mut vault Vault) superlist() string {
	mut out := '${vault.name}\n'
	for mut shelve in vault.shelves {
		out += '${shelve.superlist()}\n'
	}
	return out
}

// walk over the vault and re-shelve all dir's as owned by the vault
pub fn (mut vault Vault) hash() string {
	return sha256.hexhash(vault.superlist())
}

// restore to the unixtime state
// only implemented to go to 0, which is the first state
// TODO: implement restore on other times
pub fn (mut vault Vault) restore(unixtime int) ? {
	for mut shelve in vault.shelves {
		shelve.restore(unixtime)?
	}
}
