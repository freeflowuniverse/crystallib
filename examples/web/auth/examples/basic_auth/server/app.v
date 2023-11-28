module main

import sqlite
import vweb
import json

struct App {
	vweb.Context
mut:
	db sqlite.DB
}

@[table: 'User']
struct User {
	id       int    @[primary; sql: serial]
	username string @[sql: 'username'; unique]
	password string @[nonull]
}

fn (u User) to_json() string {
	return json.encode(u)
}

fn main() {
	db := sqlite.connect('users.db') or { panic(err) }
	sql db {
		create table User
	}
	http_port := 8000
	mut app := &App{
		db: db
	}
	vweb.run(app, http_port)
}
