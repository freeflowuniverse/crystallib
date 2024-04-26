# dbfs

a simple key value stor on filesystem, organized in 2 levels

- dbcollection, can linked to a context of hero (can be a circle or another area worth remembering things for)
- db, there can be more than 1 db per dbcollection
- the secret is specified per dbcollection 
- each subdb inherits the secret from the dbcollection but needs to be configured as encrypted

```v
import freeflowuniverse.crystallib.core.dbfs

mut dbcollection := get(context: 'test', secret: '123456')!

mut db := dbcollection.get_encrypted("db_a")!

db.set('a', 'bbbb')!
assert 'bbbb' == db.get('a')!


```

## env variables

- env variable "MYSECRET" if found will use to encrypt/decrypt .
- env variable "MYCONTEXT" if found this will be the chosen context (overrules the context as given in args)

```bash
#used to configure without having to call in code
export MYSECRET='1234'
export MYCONTEXT='mycontext'
```

## examples

Each session has such a DB attached to it, data is stored on filesystem, 

e.g. ideal for config sessions (which are done on context level)


```golang

import freeflowuniverse.crystallib.core.dbfs

mut dbcollection := get(context: 'test', secret: '123456')!

mut db := dbcollection.get_encrypted("db_a")!

//get the value
fn (mut db DB) get(name_ string) !string {

//set the key/value will go to filesystem, is organzed per context and each db has a name
fn (mut db DB) set(name_ string, data_ string) !

//check if entry exists based on keyname
fn (mut db DB) exists(name_ string) bool
	
//delete an entry
fn (mut db DB) delete(name_ string) !

//get all keys of the db (e.g. per session)
fn (mut db DB) keys(prefix string) ![]string

// delete all data
fn (mut db DB) destroy() !

```