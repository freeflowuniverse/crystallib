module flist

// list directories and files in root directory. if recursive is allowed directories are explored.
pub fn (mut f Flist) list(recursive bool) ![]Inode{
	rows := match recursive{
		true {
			f.con.exec('select * from inode;')!
		}
		false{
			f.con.exec('select * from inode where parent = 1;')!
		}
	}
	
	inodes := inodes_from_rows(rows)!

	return inodes
}

// pub fn (mut f Flist) copy() !

// delete file or directory from flist. path is relative to flist root directory.
// empty path will delete all flist entries.
// (actual data is not deleted, only flist information)
pub fn (mut f Flist) delete_path(path_ string) !{
	/*
		delete from inode table and all related tables
	*/
	mut path := path_.trim_string_right('/')

	items := path.split('/')
	mut parent := u64(1)
	mut inode := Inode{}
	for item in items{
		rows := f.con.exec_param_many('select * from inode where name = ? and parent = ?;', [item, '${parent}'])!
		
		// at most only one entry should match
		if rows.len == 0{
			return error('file or directory ${item} does not exist in flist')
		}

		inode = inode_from_row(rows[0])!
		parent = inode.ino
	}

	f.delete_inode(inode.ino)!
}


// delete any entry that matches glob
pub fn (mut f Flist) delete_match(glob string)!{
	inodes := f.find(glob)!
	for inode in inodes{
		f.delete_inode(inode.ino)!
	}
}

pub fn (mut f Flist) delete_inode(ino u64)!{
	// delete from block table
	f.con.exec_param('delete from block where ino = ?;', '${ino}')!

	// delete from extra table
	f.con.exec_param('delete from extra where ino = ?;', '${ino}')!

	// get children if any
	rows := f.con.exec_param('select * from inode where parent = ?;', '${ino}')!
	children := inodes_from_rows(rows)!
	for child in children{
		f.delete_inode(child.ino)!
	}

	// delete inode
	f.con.exec_param('delete from inode where ino = ?;', '${ino}')!
}

// pub fn (mut f Flist) merge() !

// find entries that match glob
pub fn (mut f Flist) find(glob string) ![]Inode{
	rows := f.con.exec_param('select * from inode where name glob ?', glob)!
	inodes := inodes_from_rows(rows)!

	return inodes
}

// pub fn (mut f Flist) update_routes() !