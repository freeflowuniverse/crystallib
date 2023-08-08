module twinsafe

import db.sqlite
// TODO: create 3 tables, one for othertwin, one for mytwin, one for myconfig

fn create_tables(db sqlite.DB) ! {
	sql db {
		create table MyTwin
	}!

	sql db {
		create table OtherTwin
	}!

	sql db {
		create table MyConfig
	}!
}
