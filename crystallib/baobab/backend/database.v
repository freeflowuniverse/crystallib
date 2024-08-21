module backend

import db.sqlite
import db.pg
import freeflowuniverse.crystallib.servers.postgres

pub struct Row {
pub mut:
	vals []string
}

pub struct Database {
mut:
	sqlite_db sqlite.DB
	postgres_db pg.DB
}

pub enum DatabaseType {
	sqlite
	postgres
}

@[params]
pub struct ExecParams {
	db_type DatabaseType
}

fn (mut db Database) exec(cmd string, params ExecParams) ![]Row {
	rows := match params.db_type {
		.sqlite {
			rows_ := db.sqlite_db.exec(cmd)!
			rows_.map(Row{vals: it.vals})
		}
		.postgres {
			rows_ := db.exec(cmd)!
			rows_.map(Row{vals: it.vals.map(it)})
		}
	}
	return rows
}