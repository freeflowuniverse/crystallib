# Redisclient

## basic example to connect to local redis on 127.0.0.1:6379

```v

import freeflowuniverse.crystallib.clients.redisclient

mut redis := redisclient.core_get()!
redis.set('test', 'some data') or { panic('set' + err.str() + '\n' + c.str()) }
r := redis.get('test')?
if r != 'some data' {
    panic('get error different result.' + '\n' + c.str())
}

```

> redis commands can be found on https://redis.io/commands/

