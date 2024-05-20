module flist

@[table: 'inode']
pub struct Inode {
	ino    u64 @[primary]
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