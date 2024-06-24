module couchdb

// return DB client
pub fn (mut cl CouchDBClient[Config]) dbclient(name string) !CouchDBInstance {
	// TODO: check user can login to that DB and has rights
	return CouchDBDB{}
}

@[params]
pub struct CoudDBCreateArgs {
pub mut:
	name   string
	admins []string // list of users who can login
}

pub fn (mut cl CouchDBClient[Config]) db_create(args CoudDBCreateArgs) ! {
	// TODO: create DB make sure right people can get to it
}

pub fn (mut cl CouchDBClient[Config]) db_delete(name string) ! {
	// TODO: delete DB, user will need to be admin
}

// list dbs found on connection
pub fn (mut cl CouchDBClient[Config]) db_list(name string) ![]string {
	// TODO: list the db's
	return []string{}
}
