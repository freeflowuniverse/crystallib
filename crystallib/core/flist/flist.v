module flist

import db.sqlite
import os

pub struct Flist {
	path string
	con  sqlite.DB
}

pub struct FlistGetArgs{
	path string @[required]
	create bool
}

pub fn new(args FlistGetArgs) !Flist{
	if args.create{
		os.create(args.path)!
	}

	con := sqlite.connect(args.path)!
	con.journal_mode(sqlite.JournalMode.delete)!

	return Flist{
		path: args.path,
		con: con,
	}
}
