module identity

// fn (mut identity Identity) create_user(email string) string {
// 	user := User{
// 		id: rand.uuid_v4()
// 		email: email
// 	}

// 	sql iden.db {
// 		insert user into User
// 	} or { panic('Error insterting user ${user} into identity database:${err}') }

// 	return user.id
// }