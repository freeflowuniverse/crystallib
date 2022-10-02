module pathlib

// import os
// import time

pub struct BackupArgs {
	root      string
	dest      string
	overwrite bool
}

// // start from existing name and look for name.$nr.$ext, nr need to be unique, ideal for backups
// // if dest "" then will use the directory of the fileitself + "/.backup"
// //		e.g. /code/myaccount/despiegk/somedir/test.v if
// // 		would be backed up to /code/myaccount/despiegk/somedir/.backup/test.1.v
// //		TODO: not working for now
// // root is the start of the dir we process
// //		e.g. /code/myaccount/despiegk/somedir/test.v if
// //		if source = /code/myaccount/despiegk and dest = /backup then the file will be backed up to /backup/somedir/test.1.v
// //		TODO: not working for now
// //
// // struct BackupArgs{
// // 	root string
// // 	dest string
// // 	overwrite bool
// // }
// // if overwrite this means will overwrite the last one in the directory
// pub fn (mut path Path) backup_path(args BackupArgs) ?Path {
// 	if !path.exists() {
// 		error("cannot find path, so cannot create backup for $path")
// 	}
// 	size := path.size()?
// 	mut dest := ""
// 	mut rel:= ""
// 	mut path_str := ''
// 	mut path_found := Path{}

// 	if args.dest==""{
// 		dest = path.path_dir()+"/.backup"
// 	}	
// 	if !os.exists(dest){
// 		os.mkdir_all(dest)?
// 	}

// 	if args.dest!="" || args.root!=""{
// 		panic("not implemented")
// 	}

// 	// if source != '' {
// 	// 	path_abs := path.absolute()
// 	// 	mut source_path := Path{
// 	// 		path: source
// 	// 	}.absolute()
// 	// 	if path_abs.starts_with(source_path) {
// 	// 		rel = os.dir(path_abs.substr(source_path.len + 1, path_abs.len)) + '/'
// 	// 	}
// 	// }
// 	// os.mkdir_all('$dest/$rel')?

// 	for i in 0 .. 1000 {
// 		if i == 0 {
// 			path_str = '$dest/$rel${path.name_no_ext()}.$path.extension()'
// 		} else {
// 			path_str = '$dest/$rel${path.name_no_ext()}.${i}.$path.extension()'
// 		}
// 		path_found = Path{
// 			path: path_str
// 			cat: .file
// 		}
// 		if !path_found.exists() {
// 			path_found.exist=.no
// 			return path_found
// 		}
// 		//TODO: wrong logic, we should only return the last one if the same, this might give an earlier one
// 		if size > 0 {
// 			size2 := path_found.size()?
// 			if size2 == size {
// 				// means we found the last one which is same as the one we are trying to backup
// 				path_found.exist=.yes
// 				return path_found
// 			}
// 		}
// 	}
// 	return error('cannot find path for backup, last one was: $path_found.path')
// }

// // write content to the file and make a backup, check is file
// // check backup_path() to see where the file will be backed up
// // will return the backed up file
// pub fn (mut path Path) write_backup(content string) ?Path {
// 	mut pathbackup := path.backup()?
// 	path.write(content)?
// 	return pathbackup
// }

// // create a backup, will maintain the extension
// pub fn (mut path Path) backup() ?Path {
// 	println(path.path)
// 	mut pbackup:=path.backup_path(overwrite:false)?
// 	content:=path.read()?
// 	pbackup.write(content)?
// 	return pbackup
// }

// pub fn (mut path Path) backups_remove() ? {
// 	for mut p in path.list(recursive:true)?{
// 		if p.is_dir(){
// 			if p.name() == ".backup"{
// 				p.delete()?
// 			}
// 		}
// 	}
// }

// //represents one directory in which backup was done
// struct BackupDir{
// pub mut:
// 	items []BackupItem
// 	path Path //path where the backed up items are in
// }

// pub struct BackupItem{
// pub:
// 	name string //only the base name of the file
// 	hash string
// 	time time.Time
// 	backupdir &BackupDir
// }

// //get the pathobject
// pub fn (bi BackupItem) path_get() Path {
// 	return get("${bi.backupdir.path.path}/${bi.name}")
// }	

// //save the metadata for the backups
// pub fn (mut backupdir BackupDir) metadate_save() ? {
// 	mut out :=[]string{}
// 	for item in backupdir.items{
// 		out << item.metadata()
// 	}
// }

// pub fn (mut path Path) backups_get() ? {
// 	for mut p in path.list(recursive:true)?{
// 		if p.is_dir(){
// 			if p.name() == ".backup"{
// 				p.delete()?
// 			}
// 		}
// 	}
// }
