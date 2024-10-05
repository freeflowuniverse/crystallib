# postgresql



To get started

```vlang


import freeflowuniverse.crystallib.installers.db.postgresql

mut installer:= postgresql.get()!

installer.start()!




```

## example heroscript

```hero
!!postgresql.install
    path: ''
    passwd: 'asecret'
```


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

import freeflowuniverse.crystallib.installers.db.postgresql

mut mydbinstaller:=postgresql.get()!
mydbinstaller.start()!

// now create the DB
mydbinstaller.db_create('gitea')!


```

