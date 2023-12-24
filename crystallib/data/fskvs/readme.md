# fskvs

a simple key value stor on filesystem.

## KVS

has a context in which multiple db's exist

```v
import freeflowuniverse.crystallib.data.fskvs
//this one makes sure that encryption will be used and the system can ask for the info
mut context := fskvs.new_context(context: '', encryption:true, interactive:true)!
mut db := context.get(name:'test1',encryption: true)! //force encryption

db.set("a",'bbbb')!
assert 'bbbb'==db.get("a")!

```


this kvs supports encryption

- will check on evn variable "MYSECRET" if found will use to encrypt/decrypt.

```bash
#set the secret will now be used everywhere in crystal where the fskvs is used and encryption is set
export MYSECRET='asecret'
#can also define the context as follows and the secret
export MYCONTEXT='mycontext:asecret'
```

