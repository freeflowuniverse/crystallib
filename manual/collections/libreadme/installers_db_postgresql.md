# postgresql

see the clients.postgresql for much more functionality

## see local config

```bash
#default is the instance name
hero configure -c postgres -i default -s | jq
```
jq is a nice formatter for json

## use psql

uses our hero configure output and jq command line trick

```bash
#default is the instance name
export PGPASSWORD=`hero configure -c postgres -i default -s | jq -r '.passwd'`
psql -U "root" -h localhost
```

## to use in other installer

```v

//e.g. in server configure function

import freeflowuniverse.crystallib.installers.postgresql
mut db := postgresql.get(server.config.postgresql_name)!

// now create the DB
db.db_create('gitea')!


```

