module taiga

struct UserList {
pub mut:
	users []User
}

struct User {
pub mut:
	name string
	description string
	id int
	is_private bool
	// members[]

}
