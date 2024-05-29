module smartid

import freeflowuniverse.crystallib.core.texttools
import os
import freeflowuniverse.crystallib.ui.console

__global (
	ciddb shared map[string]u32
)

fn cid_from_name(name string) !CID {
	if ciddb_exists(name)! {
		cidid := ciddb_get(name)!
		return CID{
			circle: cidid
		}
	}
	h := ciddb_highest()
	ciddb_set(name, h)!
	return CID{
		circle: h
	}
}

fn name_from_u32(id u32) !string {
	return ciddb_key_from_val(id)!
}

// the core functions with lock

fn dbpathdir() string {
	mut h := os.getenv('HOME')
	if h == '' {
		panic("can't find home env")
	}
	return '${h}/hero/db'
}

fn dbpath() string {
	return '${dbpathdir()}/cid_map.db'
}

fn ciddb_get(name_ string) !u32 {
	name := texttools.name_fix(name_)
	rlock ciddb {
		if name in ciddb {
			return ciddb[name]
		}
	}
	return error("cann't find ${name} in ciddb")
}

fn ciddb_set(name_ string, val u32) ! {
	name := texttools.name_fix(name_)
	ciddb_load()!
	lock ciddb {
		if name in ciddb {
			if ciddb[name] == val {
				return
			}
		}
		ciddb[name] = val
	}
	ciddb_save()!
}

fn ciddb_exists(name_ string) !bool {
	name := texttools.name_fix(name_)
	ciddb_load()!
	rlock ciddb {
		if name in ciddb {
			return true
		}
	}
	return false
}

fn ciddb_highest() u32 {
	mut highest := u32(1)
	rlock ciddb {
		for _, val in ciddb {
			if val > highest {
				highest = val
			}
		}
	}
	return highest
}

// find key which has his value
fn ciddb_key_from_val(id u32) !string {
	rlock ciddb {
		for key, val in ciddb {
			if val == id {
				return key
			}
		}
	}
	return error("Didn't find val in ciddb with id:'${id}'")
}

fn ciddb_load() ! {
	lock ciddb {
		if ciddb.keys().len == 0 {
			ciddb['core'] = 1
			console.print_debug(':check disk')
			if os.exists(dbpath()) {
				d := os.read_file(dbpath())!
				for line in d.split_into_lines() {
					if line.contains(':') {
						parts := line.split(':')
						if parts.len != 2 {
							panic('error in ciddb, wrong parts')
						}
						key := parts[0].trim_space()
						data := parts[1].trim_space().u32()
						ciddb[key] = data
					}
				}
			}
		}
	}
}

fn ciddb_save() ! {
	mut out := []string{}
	rlock ciddb {
		if ciddb.len == 0 {
			return
		}
		for key, val in ciddb {
			out << '${key}:${val}\n'
		}
	}
	if ciddb.len < 2 {
		os.mkdir_all(dbpathdir())!
	}
	os.write_file(dbpath(), out.join_lines())!
	// console.print_debug("write: ${out.len}")
}
