module flist

import time
import os

// list directories and files in root directory. if recursive is allowed directories are explored.
pub fn (mut f Flist) list(recursive bool) ![]Inode {
	inodes := match recursive {
		true {
			res := sql f.con {
				select from Inode
			}!
			res
		}
		false {
			res := sql f.con {
				select from Inode where parent == 1
			}!
			res
		}
	}

	return inodes
}

// copy copies an flist entry from source path to destination path.
pub fn (mut f Flist) copy(source string, destination string) ! {
	dest := destination.trim_right('/')

	src_inode := f.get_inode_from_path(source)!

	if _ := f.get_inode_from_path(dest) {
		return error('${dest} exists')
	}

	dest_parent := if dest.contains('/') {
		dest.all_before_last('/')
	} else {
		''
	}

	dest_parent_inode := f.get_inode_from_path(dest_parent)!
	dest_inode := Inode{
		parent: dest_parent_inode.ino
		ctime: time.now().unix()
		mtime: time.now().unix()
		mode: src_inode.mode
		name: dest.all_after_last('/')
		rdev: src_inode.rdev
		size: src_inode.size
		gid: u32(os.getgid())
		uid: u32(os.getuid())
	}

	sql f.con {
		insert dest_inode into Inode
	}!

	dest_ino := u64(f.con.last_id())

	f.copy_blocks(src_inode.ino, dest_ino)!
	f.copy_extras(src_inode.ino, dest_ino)!

	children := sql f.con {
		select from Inode where parent == src_inode.ino
	}!

	for child in children {
		f.copy(os.join_path(source, child.name), os.join_path(dest, child.name))!
	}
}

fn (mut f Flist) copy_blocks(src_ino u64, dest_ino u64) ! {
	mut blocks := sql f.con {
		select from Block where ino == src_ino
	}!

	for mut block in blocks {
		block.ino = dest_ino
		sql f.con {
			insert block into Block
		}!
	}
}

fn (mut f Flist) copy_extras(src_ino u64, dest_ino u64) ! {
	mut extras := sql f.con {
		select from Extra where ino == src_ino
	}!

	for mut extra in extras {
		extra.ino = dest_ino
		sql f.con {
			insert extra into Extra
		}!
	}
}

fn (mut f Flist) copy_inode(src Inode, dest Inode) ! {
}

fn (mut f Flist) get_inode_from_path(path_ string) !Inode {
	mut path := path_.trim('/')

	items := path.split('/')
	root_inodes := sql f.con {
		select from Inode where ino == 1
	}!

	if root_inodes.len != 1 {
		return error('invalid flist: failed to get root directory inode')
	}

	mut inode := root_inodes[0]
	if path == '' {
		return inode
	}

	for item in items {
		if item == '' {
			return error('invalid path ${path_}')
		}

		inodes := sql f.con {
			select from Inode where name == item && parent == inode.ino
		}!

		// at most only one entry should match
		if inodes.len == 0 {
			return error('file or directory ${item} does not exist in flist')
		}

		inode = inodes[0]
	}

	return inode
}

// delete file or directory from flist. path is relative to flist root directory.
// empty path will delete all flist entries.
// (actual data is not deleted, only flist information)
pub fn (mut f Flist) delete_path(path_ string) ! {
	/*
		delete from inode table and all related tables
	*/
	inode := f.get_inode_from_path(path_) or {
		return error('failed to get inode from path: ${err}')
	}

	f.delete_inode(inode.ino) or { return error('failed to delete inode: ${err}') }
}

// delete_match deletes any entry that matches pattern. it simply calls find() and deletes matching inodes.
pub fn (mut f Flist) delete_match(pattern string) ! {
	inodes := f.find(pattern)!
	for inode in inodes {
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
		select from Inode where parent == ino
	}!

	for child in children {
		f.delete_inode(child.ino)!
	}

	// delete inode
	f.con.exec_param('delete from inode where ino = ?;', '${ino}')!
}

// pub fn (mut f Flist) merge() !

// find entries that match pattern, it uses the `LIKE` operator;
// The percent sign (%) matches zero or more characters and the underscore (_) matches exactly one.
pub fn (mut f Flist) find(pattern string) ![]Inode {
	inodes := sql f.con {
		select from Inode where name like pattern
	}!

	return inodes
}

// pub fn (mut f Flist) update_routes() !
