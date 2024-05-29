## Vlang ZDB Client

to use:

- build zero db from source: https://github.com/threefoldtech/0-db
- run zero db from root of 0db folder:
  `./zdbd/zdb --help || true` for more info

## to use test

```bash
#must set unix domain with --socket argument when running zdb
#run zdb as following:  
mkdir -p ~/.zdb
zdb --socket ~/.zdb/socket --admin 1234
redis-cli -s ~/.zdb/socket
#or easier:
redis-cli -s ~/.zdb/socket --raw nsinfo default
```

then in the redis-cli can do e.g.

```
nsinfo default
```

