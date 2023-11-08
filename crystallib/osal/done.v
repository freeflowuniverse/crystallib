module osal

import freeflowuniverse.crystallib.core.texttools
import os

__global (
	donedb  shared  map[string]string
)


// Marks the execution of a command with a specific key as done by putting it in the hset exec.done in redis
pub fn done_set(key string, val string) ! {
	donedb_set(key,val)!
}

// Tries to retrieve the value (string value) of a command that was executed by looking in the hset exec.done in redis, this function returns none in case it is not found in the hset
pub fn done_get(key string) ?string {
	return donedb_get(key)
}

pub fn done_delete(key string) ! {
	return donedb_delete(key)
}

pub fn done_get_str(key string) string {
	val:=done_get(key) or { panic(err) }
	return val
}

// Tries to retrieve the value (integer value) of a command that was executed by looking in the hset exec.done in redis, this function returns 0 in case it is not found in the hset
pub fn done_get_int(key string) int {
	val:=done_get(key) or { panic(err) }
	return val.int()
}

// Returns true if the command has been executed (if it is found in the hset exec.done) and false in the other case
pub fn done_exists(key string) bool {
	return donedb_exists(key) or { panic(err) }
}

// Logs all the commands that were executed on this system (looks in the hset exec.done to do so)
pub fn done_print() ! {
	mut logger := get_logger()
	mut output := 'DONE:\n'
	for key in donedb_keys() {
		output += '\t${key} = ${donedb_get(key)!}\n'
	}
	logger.info('${output}')
}

// Remove all knowledge of executed commands
pub fn done_reset() ! {
	donedb_reset()!
}



//the core functions with lock 


fn dbpathdir() string{
	mut h:=os.getenv("HOME")
	if h==""{
		panic("can't find home env")
	}
	return "${h}/hero/db"
}

fn dbpath() string{
	return "${dbpathdir()}/dbdone.db"
}


fn donedb_get(name_ string) ?string {
	name:=texttools.name_fix(name_)
	rlock donedb{		
		if name in donedb{
			return donedb[name]
		}
	}	
	return none
}

fn donedb_delete(name_ string) ! {
	name:=texttools.name_fix(name_)
	rlock donedb{		
		if name in donedb{
			donedb.delete(name)
		}else{
			return
		}
	}	
	donedb_save()!
}


fn donedb_set(name_ string, val string) ! {
	name:=texttools.name_fix(name_)
	donedb_load()!
	lock donedb{		
		if name in donedb{
			if donedb[name] == val{
				return
			}
		}
		donedb[name]=val
	}	
	donedb_save()!
}

fn donedb_exists(name_ string) !bool {
	name:=texttools.name_fix(name_)
	donedb_load()!
	rlock donedb{		
		if name in donedb{
			return true
		}
	}
	return false
}

fn donedb_keys() []string {
	rlock donedb{		
		return donedb.keys()
	}
	panic("bug")
}


// //find key which has his value
// fn donedb_key_from_val(id string) !string {
// 	rlock donedb{
// 		for key,val in donedb{
// 			if val==id{
// 				return key
// 			}
// 		}
// 	}
// 	return error("Didn't find val in donedb with id:'$id'")
// }


fn donedb_load() ! {
	lock donedb{
		if donedb.keys().len==0{
			if os.exists(dbpath()){
				d:=os.read_file(dbpath())!
				for line in d.split_into_lines(){
					if line.contains(":"){
						parts:=line.split(":")
						if parts.len!=2{
							panic("error in donedb, wrong parts")
						}
						key:=parts[0].trim_space()
						data:=parts[1].trim_space()
						donedb[key]=data
					}
				}
			}
		}
	}
}


fn donedb_save() !{
	mut out:=[]string{}
	rlock donedb{		
		if donedb.len==0{
			return
		}
		for key,val in donedb{
			out<<"$key:$val\n"
		}
	}
	if donedb.len<2{
		os.mkdir_all(dbpathdir())!
	}
	os.write_file(dbpath(),out.join_lines())!
	// println("write: ${out.len}")
}

fn donedb_reset() !{
	rlock donedb{		
		donedb=map[string]string{}
	}
	donedb_save()!
}



