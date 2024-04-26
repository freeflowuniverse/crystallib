# Play

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

- each time we execute a playbook using heroscript we do it in a session
- a session can have a name as given by the developer or will be autocreated based on time

> more info see [session](session.md)

## Config Mgmt

is done per instance of an object which inherits from BaseConfig.

- see [base](base.md)
- see [config](config.md)

## KVS

there is a KVS attached to each context/session

- see [kvs](kvs.md)
