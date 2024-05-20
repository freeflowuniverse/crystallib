module flist

import os
import db.sqlite
import rand
import time

fn testsuite_begin() {
	schema := [
		'CREATE TABLE inode (
    ino INTEGER PRIMARY KEY AUTOINCREMENT,
    parent INTEGER,
    name VARCHAR(255),
    size INTEGER,
    uid INTEGER,
    gid INTEGER,
    mode INTEGER,
    rdev INTEGER,
    ctime INTEGER,
    mtime INTEGER
);',
		'CREATE INDEX parents ON inode (parent);',
		'CREATE INDEX names ON inode (name);',
		'CREATE TABLE extra (
    ino INTEGER PRIMARY KEY,
    data VARCHAR(4096)
);',
		'CREATE TABLE block (
    ino INTEGER,
    id VARCHAR(32),
    key VARCHAR(32)
);',
		'CREATE INDEX block_ino ON block (ino);',
		'CREATE TABLE tag (
    key VARCHAR(10) PRIMARY KEY,
    value VARCHAR(255)
);',
		'CREATE TABLE route (
    start integer, -- one byte hash prefix
    end integer, -- one byte hash prefix
    url VARCHAR(2048)
);',
	]
	os.create('/tmp/fl1.fl')!
	mut con := sqlite.connect('/tmp/fl1.fl')!
	con.journal_mode(sqlite.JournalMode.delete)!

	for schematic in schema {
		con.exec(schematic)!
	}

	con.close()!
}

fn testsuite_end() {
	os.rm('/tmp/fl1.fl')!
}

fn test_list() {
	mut fl := new('/tmp/fl1.fl')!
	input := insert_random_inodes(mut fl)!
	list := fl.list(true)!
	assert input == list
}

fn insert_random_inodes(mut fl Flist) ![]Inode {
	mut input := []Inode{}
	input << Inode{
		ino: 1
		parent: 0
		name: '/'
		size: rand.u64() % 100
		uid: rand.u32() % 10000
		gid: rand.u32() % 10000
		rdev: 0
		mode: 16384
		ctime: time.now().unix()
		mtime: time.now().unix()
	}

	for i in 2 .. 10 {
		input << Inode{
			ino: i
			parent: i % 3 + 1
			name: rand.string(5)
			size: rand.u64() % 100
			uid: rand.u32() % 10000
			gid: rand.u32() % 10000
			rdev: 0
			mode: 32768
			ctime: time.now().unix()
			mtime: time.now().unix()
		}
	}

	for inode in input {
		fl.con.exec_param_many('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);',
			['${inode.ino}', '${inode.parent}', '${inode.name}', '${inode.size}', '${inode.uid}',
			'${inode.gid}', '${inode.mode}', '${inode.rdev}', '${inode.ctime}', '${inode.mtime}'])!
	}

	return input
}

fn test_delete_path() {
	mut fl := new('/tmp/fl1.fl')!
	fl.con.exec('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (100, 1, "dir", 0, 0, 0, 0, 0, 0, 0)')!
	fl.con.exec('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (101, 100, "file", 0, 0, 0, 0, 0, 0, 0)')!
	fl.con.exec('insert into block (ino, id, key) values (101, "asdf", "qwer");')!
	fl.con.exec('insert into extra (ino, data) values (101, "data");')!

	fl.delete_path('dir/file')!

	assert fl.con.exec('select * from inode where ino = 101;')!.len == 0
	assert fl.con.exec('select * from block where ino = 101;')!.len == 0
	assert fl.con.exec('select * from extra where ino = 101;')!.len == 0
}

fn test_find() {
	mut fl := new('/tmp/fl1.fl')!

	fl.con.exec('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (100, 1, "dir1", 0, 0, 0, 0, 0, 0, 0)')!
	fl.con.exec('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (101, 1, "dir2", 0, 0, 0, 0, 0, 0, 0)')!

	inodes := fl.find('dir%')!
	assert inodes.len == 2
}

fn test_delete_match() {
	mut fl := new('/tmp/fl1.fl')!

	fl.con.exec('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (102, 1, "dir3", 0, 0, 0, 0, 0, 0, 0)')!
	fl.con.exec('insert into inode (ino, parent, name, size, uid, gid, mode, rdev, ctime, mtime) values (103, 1, "dir4", 0, 0, 0, 0, 0, 0, 0)')!

	fl.delete_match('dir%')!

	inodes := fl.find('dir%')!
	assert inodes.len == 0
}
