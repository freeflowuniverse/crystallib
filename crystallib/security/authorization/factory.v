module authorization

import db.pg
import db.sqlite
import os
import freeflowuniverse.crystallib.baobab.actor
import freeflowuniverse.crystallib.baobab.backend {DBIdentifier, Database}

pub fn new() !Authorizer {

	return Authorizer{
		Actor: actor.new(
		indexer: backend.new_indexer(
			Database{
				sqlite_db: sqlite.connect('${os.home_dir()}/hero/db/authorizer_indexer.sqlite')!
			},
			reset: true
		)!,
		identifier: DBIdentifier{
			db: pg.connect(pg.Config{
				host: 'localhost'
				port: 5432
				user: 'admin'
				password: 'test'
				dbname: 'default'
			})!
		}
	)!
	}
}