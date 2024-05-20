module flist

// list directories and files in root directory. if recursive is allowed directories are explored.
pub fn (mut f Flist) list(recursive bool) ![]Inode{
	inodes := match recursive {
		true {
			res := sql f.con {
				select from Inode
			}!
			res
		}
		false{
			res := sql f.con {
				select from Inode where parent == 1
			}!
			res
		}
	}

	return inodes
}

// pub fn (mut f Flist) copy() !

// delete file or directory from flist. path is relative to flist root directory.
// empty path will delete all flist entries.
// (actual data is not deleted, only flist information)
pub fn (mut f Flist) delete_path(path_ string) ! {
	/*
		delete from inode table and all related tables
	*/
	mut path := path_.trim_string_right('/')

	items := path.split('/')
	mut parent := u64(1)
	mut inode := Inode{}
	for item in items{
		inodes := sql f.con{
			select from Inode where name == item && parent == parent
		}!

		// at most only one entry should match
		if inodes.len == 0{
			return error('file or directory ${item} does not exist in flist')
		}

		inode = inodes[0]
		parent = inode.ino
	}

	f.delete_inode(inode.ino)!
}


// delete_match deletes any entry that matches pattern. it simply calls find() and deletes matching inodes.
pub fn (mut f Flist) delete_match(pattern string)!{
	inodes := f.find(pattern)!
	for inode in inodes{
		f.delete_inode(inode.ino)!
	}
}

pub fn (mut f Flist) delete_inode(ino u64) ! {
	// delete from block table
	f.con.exec_param('delete from block where ino = ?;', '${ino}')!

	// delete from extra table
	f.con.exec_param('delete from extra where ino = ?;', '${ino}')!

	// get children if any
	children := sql f.con {
		select form Inode where parent == ino
	}!

	for child in children{
		f.delete_inode(child.ino)!
	}

	// delete inode
	f.con.exec_param('delete from inode where ino = ?;', '${ino}')!
}

// pub fn (mut f Flist) merge() !

// find entries that match pattern, it uses the `LIKE` operator; 
// The percent sign (%) matches zero or more characters and the underscore (_) matches exactly one.
pub fn (mut f Flist) find(pattern string) ![]Inode{
	inodes := sql f.con {
		select from Inode where name like pattern
	}!

	return inodes
}

// pub fn (mut f Flist) update_routes() !
