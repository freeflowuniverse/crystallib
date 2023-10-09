module people

[params]
pub struct Email {
pub mut:
	addr string
}

[params]
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

// //add person based on smartid
// pub fn (mut contacts Contacts) add(mut &SmartId) &Person {
// 	mut c:=Person
// 	constacts.contacts << &c
// 	return &c
// }

// Add email address
// ARGS:
// - Email
pub fn (mut person Person) email_add(email Email) {
	person.emails << &email
	// TODO any possible checks)
}

// Add telephone
// ARGS:
// - Tel
pub fn (mut person Person) tel_add(tel Tel) {
	person.tel << &tel
	// TODO any possible checks
}

// Add address
// ARGS:
// - Address
pub fn (mut person Person) address_add(addr Address) {
	person.addresses << &addr
	// TODO any possible checks
}
