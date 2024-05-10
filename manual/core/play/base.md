
# Base Context & Session

Important section about how to create base objects which hold context an config mgmt.

## Context

A context is sort of sandbox in which we execute our scripts it groups the following

- filesystem key value stor
- logs
- multiple sessions
- gittools: gitstructure
- redis client

> more info see [context](context.md)

## Session

- each time we execute something with a client or other sal we do this as part of a session
- a session can have a name as given by the developer or will be autocreated based on time

> more info see [session](session.md)

## Config Mgmt

is done per instance of an object which inherits from BaseConfig.

- see [base](base.md)
- see [config](config.md)

## KVS

there is a KVS attached to each context/session

- see [kvs](kvs.md)


# BaseConfig

Clients, DALs, SAL's can inherit base


```golang

pub struct BaseConfig {
pub mut:
	session_ ?&Session 
	instance    string
}

//how to use

import freeflowuniverse.crystallib.core.base

pub struct B2Client {
	play.BaseConfig
pub mut:
	someprop string
}



```

## BaseConfig Methods

This will give some super powers to each base inheritted class


```v

// return a session which has link to the actions and params on context and session level
// the session also has link to dbfs (filesystem key val stor and gitstructure if relevant)
//```
// context             ?&Context      @[skip; str: skip]
// session             ?&Session      @[skip; str: skip]
// context_name        string = 'default'
// session_name        string //default will be based on a date when run
// interactive         bool = true //can ask questions, default on true
//```

pub fn (mut self BaseConfig) session(args PlayArgs) &Session

pub fn (mut self BaseConfig) context() &Context


```