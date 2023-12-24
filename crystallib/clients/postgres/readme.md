# postgres client

## use hero to work with postgres

```bash

Usage: hero postgres [flags] [commands]

manage postgresql

Flags:
  -help               Prints help information.
  -man                Prints the auto-generated manpage.

Commands:
  exec                execute a query
  check               check the postgresql connection
  configure           configure a postgresl connection.
  backup              backup
  print               print configure info.
  list                list databases

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