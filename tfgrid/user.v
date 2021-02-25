module tfgrid

//definition of user

struct User{
	id int
	name string
	pubkey string

}

//this is the user who owns the digital twin
//can be more than 1
struct Owner{
	id int
	name string
	pubkey string
	privkey string
}


//for Owner needs methods to create/use private/public key pair (nacl is available now for vlang)
//can ask Alexander if issues somewhere