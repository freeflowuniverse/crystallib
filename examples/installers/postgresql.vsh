#!/usr/bin/env v -w -enable-globals run


import freeflowuniverse.crystallib.installers.postgresql

mut db := postgresql.new(passwd: '12', reset: true)!
db.db_create('works')!
