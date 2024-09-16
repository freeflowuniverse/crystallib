module heroweb
import jwt
import veb

@['/register'; post]
pub fn (app &App) register(mut ctx Context) veb.Result {
	email := ctx.form['email'] or { return ctx.text('Email is required') }
	
	// Create JWT token
	claims := User{
		email: [email]
	}
	alg := jwt.new_algorithm(jwt.AlgorithmType.hs256)
	jwt_token := jwt.encode<User>(claims, alg, app.secret_key, 1000 * 60 * 60) or {
		return ctx.text('Failed to create JWT token')
	}

	println(jwt_token)
	
	// // Store the token in the user's web browser local storage
	// ctx.set_cookie('jwt_token', jwt_token, max_age : 24 * 60 * 60 * 10 ) //10 days
	
	// // In a real-world scenario, you would send an email with a verification link here
	// // For this example, we'll just return the token
	// return ctx.json({
	// 	'token': jwt_token
	// })
	
	return ctx.html("Check your email for the verification link")
}

// @['/verify/:token']
// pub fn (app &App) verify(mut ctx Context, token string) veb.Result {
// 	alg := jwt.new_algorithm(jwt.AlgorithmType.hs256)
// 	claims := jwt.verify<User>(token, alg, app.secret_key) or {
// 		return ctx.text('Invalid or expired token')
// 	}
	
// 	// In a real-world scenario, you would mark the user as verified in your database here
// 	return ctx.json({
// 		'message': 'User verified successfully',
// 		'email': claims.email
// 	})
// }


@['/signin']
pub fn (app &App) signin(mut ctx Context) veb.Result {
	d:=$tmpl("templates/login.html")
	return ctx.html(d)
}
