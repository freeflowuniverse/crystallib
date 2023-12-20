# postgres client

## use hero to configure

```markdown

hero configure postgres

## Configure Postgresql Client
==============================



```

## configure

the postgres configuration is stored on the filesystem for further use, can be configured as follows

```v
import freeflowuniverse.crystallib.clients.postgres

postgres.configure(name:'default',
	user :'root'
	port : 5432
	host  : 'localhost'
	password : 'ssss'
	dbname :'postgres')!

mut db:=postgres.get(name:'default')!

```

## configure through 3script

```v
import freeflowuniverse.crystallib.clients.postgres

script3:='
!!postgresclient.define name:'default'
	//TO IMPLEMENT
'


postgres.configure(script3:script3)!


//can also be done through get directly
mut cl:=postgres.get(reset:true,name:'default',script3:script3)

```


## some postgresql cmds

```v
import freeflowuniverse.crystallib.clients.postgres

mut cl:=postgres.get()! //will default get postgres client with name 'default'

cl.db_exists("mydb")!

```

## use the good module of v

- [https://modules.vlang.io/db.pg.html#DB.exec](https://modules.vlang.io/db.pg.html#DB.exec)