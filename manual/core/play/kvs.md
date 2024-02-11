

## DB per session

Each session has a KVS attached to it, data is stored on filesystem, e.g. ideal for config sessions (which are done on context level)

> fn (mut self Session) db_get() !fskvs.DB

```golang

//get the value
fn (mut db DB) get(name_ string) !string {

//set the key/value will go to filesystem, is organzed per context and each db has a name
fn (mut db DB) set(name_ string, data_ string) !

//check if entry exists based on keyname
fn (mut db DB) exists(name_ string) bool
	
//delete an entry
fn (mut db DB) delete(name_ string) !

//get all keys of the db (e.g. per session)
fn (mut db DB) keys() ![]string

//get all keys with certain prefix
fn (mut db DB) prefix(prefix string) ![]string 

// delete all data
fn (mut db DB) destroy() !

```