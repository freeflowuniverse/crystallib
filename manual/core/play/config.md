# Config

We try to make a std way how to do configuration, this is using the [kvs](kvs.md) underneith.

## How to use

A good example to look at is [crystallib/clients/b2](crystallib/clients/b2)

```golang


```

## Implemented as a generic

T is the generic

```golang

struct ConfiguratorArgs {
	context  &Context
	configtype     string
	instance string   @[required]
}

// name is e.g. mailclient (the type of configuration setting)
// instance is the instance of the config e.g. kds
// the context defines the context in which we operate, is optional will get the default one if not set
fn configurator_new[T](args ConfiguratorArgs) !Configurator[T]

//THE CONFIGURATOR AND ITS METHODS

struct Configurator[T] {
	context  &Context
	configtype     string // e.g. sshclient
	instance string
}

fn (mut self Configurator[T]) config_key() string 

fn (mut self Configurator[T]) set(args_ T) ! 

fn (mut self Configurator[T]) exists() !bool

fn (mut self Configurator[T]) get() !T 

fn (mut self Configurator[T]) reset() ! 

fn (mut self Configurator[T]) getset(args T) !T 

fn (mut self Configurator[T]) list() ![]string 

struct PrintArgs {
	name string
}
fn (mut self Configurator[T]) configprint(args PrintArgs) !

```