module flist

import db.sqlite

pub struct Flist {
	path string
	con sqlite.DB
}

pub fn new(path string) !Flist{
	con := sqlite.connect(path)!
	con.journal_mode(sqlite.JournalMode.delete)!

	return Flist{
		path: path,
		con: con,
	}
}