module tfgrid
import json
//definition of user

struct Group{
	id int
	name string
	users []User
	groups []Group
}

//return users who make up the group
// need to use the recursive behaviour
pub fn (mut group Group) users_get() ?[]User{
	return []User{}
}


//needs methods to create/use private/public key pair (nacl is available now for vlang)
//can ask Alexander if issues somewhere