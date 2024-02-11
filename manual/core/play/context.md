

# Context

## Get a context


```js
cid       string // rid.cid or just cid
name      string // a unique name in cid
params    paramsparser.Params
redis     &redisclient.Redis
contextdb &fskvs.ContextDB  
```    

- cid is the unique id for a circle.
- the default context is "default"
- each context can have params attached to it, as can be set by the heroscripts
- each context has a redis client (can be a different per context but normally not)
- context db is a fs db (key value stor)


```golang
import freeflowuniverse.crystallib.core.play


struct ContextGetArgs {
	name        string = "default" // a unique name in cid
	interactive bool = true
}

//get context based on name, can overrule interactivity
play.context_get(args_ ContextGetArgs) !Context


```

## Work with a context

E.g. gitstructure is linked to a context

```golang

//return the gistructure as is being used in context
fn (mut self Context) gitstructure() !&gittools.GitStructure 

//reload gitstructure from filesystem
fn (mut self Context) gitstructure_reload()

//return the coderoot as is used in context
fn (mut self Context) coderoot() !string 

// load the context params from redis
fn (mut self Context) load() !

// save the params to redis
fn (mut self Context) save() !

```

## get a custom DB from context

```golang

//get a unique db with a name per context
fn (mut self Context) db_get(dbname string) !fskvs.DB 

//get configuration DB is always per context
fn (mut self Context) db_config_get() !fskvs.DB

```


## Configure a context

A context can get certain configuration e.g. params, coderoot, ... (in future encryption), configuration is optional.

```golang

// configure a context object
// params:
// ```
// cid          string = "000" // rid.cid or cid allone
// name         string // a unique name in cid
// params       string
// coderoot	 string
// interactive  bool
// ```
fn context_configure(args_ ContextConfigureArgs) ! 

```