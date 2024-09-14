module main

import veb
import json
import net.http
import db.sqlite

pub struct App {
	veb.StaticHandler
mut:
	db sqlite.DB
}

pub struct Context {
	veb.Context
}

pub struct User {
pub mut:
	id       int
	username string
	password string
}

pub struct CustomResponse {
	status  int
	message string
}

pub fn (mut app App) before_request(mut ctx Context) bool {
	basic_auth({
		'Emad': '0000'
	}, mut ctx) or { panic(err) }
	return true
}

@['/users'; post]
pub fn (mut app App) register(mut ctx Context) veb.Result {
	user := json.decode(User, ctx.req.data) or {
		ctx.set_status(400, 'Bad Request')
		er := CustomResponse{400, 'Invalid JSON'}
		return ctx.json(er)
	}

	user_found := app.db.exec_param('SELECT * FROM User WHERE username = ?', user.username) or {
		[]
	}
	if user_found.len > 0 {
		ctx.set_status(400, 'Bad Request')
		er := CustomResponse{400, 'Username must be unique'}
		return ctx.json(er)
	}

	app.db.exec_param('INSERT INTO User (username, password) VALUES (?, ?)', user.username,
		user.password) or { panic(err) }
	new_id := app.db.last_insert_rowid()
	created := User{int(new_id), user.username, user.password}
	ctx.set_status(201, 'Created')
	return ctx.json(created)
}

@['/users'; get]
pub fn (mut app App) login(mut ctx Context) veb.Result {
	authorization := ctx.req.header.get(http.CommonHeader.authorization) or {
		ctx.set_status(401, 'Unauthorized')
		return ctx.json(CustomResponse{401, 'Authorization header missing'})
	}
	sig := decode(authorization)
	fields := sig.split(':')
	username, password := fields[0], fields[1]

	user_found := app.db.exec_param('SELECT * FROM User WHERE username = ? AND password = ?',
		username, password) or { [] }
	if user_found.len == 0 {
		ctx.set_status(404, 'Not Found')
		er := CustomResponse{404, 'User not found'}
		return ctx.json(er)
	}

	ctx.set_status(200, 'Successfully Logged in')
	return ctx.json(user_found[0])
}

fn main() {
	mut app := App{
		db: sqlite.connect('users.db')!
	}
	veb.run[App, Context](mut app, 8080)
}
