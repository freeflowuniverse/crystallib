#!/usr/bin/env -S v -n -w -enable-globals run


import freeflowuniverse.crystallib.installers.db.postgresql
import time

mut db := postgresql.start(passwd: '12')!
db.db_create('works')!
db.stop()!
db.start()!