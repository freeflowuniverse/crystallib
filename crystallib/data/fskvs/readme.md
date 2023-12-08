# fskvs

a simple key value stor on filesystem.


## this kvs supports encryption

will check on evn variable "MYSECRET" if found will use to encrypt/decrypt.

```golang
import freeflowuniverse.crystallib.data.fskvs
mut db:=new(name:"test", secret:"1234")!

db.set("a",'bbbb')!
assert 'bbbb'==db.get("a")!

```

if you want to make sure secret was set and encryption will be used

```bash
#set the secret will now be used everywhere in crystal where the fskvs is used and encryption is set
export MYSECRET='asecret'
```

```golang
import freeflowuniverse.crystallib.data.fskvs
mut db:=new(name:"test", encryption:true)!

db.set("a",'bbbb')!
assert 'bbbb'==db.get("a")!

```
