module main

import vweb
import json
import net.http

fn (mut app App) before_request() {
	basic_auth({
		'Emad': '0000'
	}, mut app) or { panic(err) }
}

@['/users'; post]
fn (mut app App) register() vweb.Result {
	// Register a new user into database
	// to make sure that login function working well.
	user := json.decode(User, app.req.data) or {
		app.set_status(400, 'Bad Request')
		er := CustomResponse{400, invalid_json}
		return app.json(er.to_json())
	}
	// To make sure the username is unique.
	user_found := sql app.db {
		select from User where username == user.username
	}
	if user_found.len > 0 {
		app.set_status(400, 'Bad Request')
		er := CustomResponse{400, user_unique}
		return app.json(er.to_json())
	}
	sql app.db {
		insert user into User
	}
	new_id := app.db.last_id() as int
	created := User{new_id, user.username, user.password}
	app.set_status(201, 'created')
	return app.json(created.to_json())
}

@['/users'; get]
fn (mut app App) login() ?vweb.Result {
	// To test basic_auth middleware, we need to check if the credentials are valid.
	// Then we can make a condition on request based on this valid.
	authorization := app.Context.req.header.get(http.CommonHeader.authorization)?
	sig := decode(authorization)
	fileds := sig.split(':')
	username, password := fileds[0], fileds[1]
	user_found := sql app.db {
		select from User where username == username && password == password
	}
	if user_found == [] {
		app.set_status(404, 'Not Found')
		er := CustomResponse{404, user_not_found}
		return app.json(er.to_json())
	}
	ret := json.encode(user_found)
	app.set_status(200, 'Successfully Logged in')
	return app.json(ret)
}
