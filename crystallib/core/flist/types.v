module flist

@[table: 'inode']
pub struct Inode {
	ino    u64    @[primary; sql: serial]
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

@[table: 'block']
pub struct Block {
pub mut:
	ino u64
	id  string
	key string
}

@[table: 'extra']
pub struct Extra {
pub mut:
	ino  u64
	data string
}

@[table: 'route']
pub struct Route {
pub mut:
	start u8
	end   u8
	url   string
}
