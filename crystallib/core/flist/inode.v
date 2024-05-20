module flist

import db.sqlite
import strconv

pub struct Inode {
	ino    u64
	parent u64
	name   string
	size   u64
	uid    u32
	gid    u32
	mode   u32
	rdev   u64
	ctime  i64
	mtime  i64
}

fn inode_from_row(row sqlite.Row) !Inode {
	if row.vals.len != 10 {
		return error('invalid row content; expected 10 fields')
	}

	ino := strconv.parse_uint(row.vals[0], 10, 64) or {
		return error('failed to parse ino: ${err}')
	}
	parent := strconv.parse_uint(row.vals[1], 10, 64) or {
		return error('failed to parse parent: ${err}')
	}
	name := row.vals[2]
	size := strconv.parse_uint(row.vals[3], 10, 32) or {
		return error('failed to parse size: ${err}')
	}
	uid := u32(strconv.parse_uint(row.vals[4], 10, 32) or {
		return error('failed to parse uid: ${err}')
	})
	gid := u32(strconv.parse_uint(row.vals[5], 10, 32) or {
		return error('failed to parse gid: ${err}')
	})
	mode := u32(strconv.parse_uint(row.vals[6], 10, 32) or {
		return error('failed to parse mode: ${err}')
	})
	rdev := strconv.parse_uint(row.vals[7], 10, 64) or {
		return error('failed to parse rdev: ${err}')
	}
	ctime := strconv.parse_int(row.vals[8], 10, 64) or {
		return error('failed to parse ctime: ${err}')
	}
	mtime := strconv.parse_int(row.vals[9], 10, 64) or {
		return error('failed to parse mtime: ${err}')
	}

	return Inode{ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime}
}

fn inodes_from_rows(rows []sqlite.Row) ![]Inode {
	mut inodes := []Inode{}
	for row in rows {
		inodes << inode_from_row(row) or { return error('failed to parse inode from row: ${err}') }
	}

	return inodes
}
