module people

enum ContactsState{
	init		 //is still init mode, empty
	smartids	 //the smartid's are known
	loaded		 //the contact data has been fetched
}

[heap]
pub struct Contacts {
	system.Base	
pub mut:
	contacts []Contact
	state 
}


[heap]
pub struct Contact {
pub mut:
	firstname   string
	lastname    string
	description string
	emails      []&Email
	tel         []&Tel
	addresses   []&Address
}

pub struct ContactNewArgs {
pub mut:
	firstname   string
	lastname    string
	description string
}

pub struct Email {
pub mut:
	addr string
}

pub struct Tel {
pub mut:
	addr        string
	countrycode string
}

pub struct Address {
pub mut:
	street_nr  string
	city       string
	postalcode string
	country    &Country
}

//add a contact which will be owned by the local twin
pub fn (mut contacts Contacts) new() &Contact {
	mut c:=Contact{}
	constacts.contacts << &c
	return &c
}

// //add contact based on smartid
// pub fn (mut contacts Contacts) add(mut &SmartId) &Contact {
// 	mut c:=Contact
// 	constacts.contacts << &c
// 	return &c
// }



// Add email address
// ARGS:
// - Email
pub fn (mut contact Contact) email_add(email Email) {
	contact.emails << &email 
	// TODO any possible checks)
}

// Add telephone
// ARGS:
// - Tel
pub fn (mut contact Contact) tel_add(tel Tel) {
	contact.tel << &tel
	// TODO any possible checks
}

// Add address
// ARGS:
// - Address
pub fn (mut contact Contact) address_add(addr Address) {
	contact.addresses << &addr
	// TODO any possible checks
}
