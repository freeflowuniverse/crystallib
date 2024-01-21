# fskvs

a simple key value stor on filesystem, organized in 2 levels

- contextdb level, linked to a context of crystal
- db level, there can be more than 1 db per context
- the secret is specified per contextdb (if applicable)
- each db inherits the secret from the parent but needs to be configured as encrypted

```v
import freeflowuniverse.crystallib.data.fskvs

//this one makes sure that encrypted will be used and the system can ask for the info
contextdb_configure(name: 'mycontext', encrypted: true)! 
//default contextdb is 'default'

mut contextdb := contextdb_get(name: 'mycontext')!

//give me a db which will be encrypted with the secret as was specified on the contextdb level
contextdb.db_configure(dbname:"mydb",encrypted:true)!

mut db := contextdb.db_get()! //will be the default one

db.set("a",'bbbb')!
assert 'bbbb'==db.get("a")!

```


```bash
#can also define the secret per contextdb as follows and the secret
export MYCONTEXT='mycontext:asecret'
```

