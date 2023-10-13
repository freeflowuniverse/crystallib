## use zinit

Zinit is our own init manager from ZOS

```golang
module goca

import freeflowuniverse.crystallib.osal.docker
import threefoldtech.vbuilder.core.gobuilder

pub fn build(args docker.BuildArgs) ! {
	mut engine := args.engine
	
	// make sure dependency has been build
	gobuilder.build(engine: engine, reset: args.reset, strict: args.strict)!

	// specify we want to build an alpine version
	mut r := engine.recipe_new(name: 'goca', platform: .alpine)
    
    //A LOT OF THINGS MIGHT HAVE BEEN ADDED HERE TO THE DOCKER RECIPE

	r.add_env('CAPATH' ,'/goca/data')!
	r.add_workdir(workdir:"/goca/data")!
	r.add_expose(ports:['80'])!

	//HERE we add 3 services to the docker
	r.add_zinit_cmd(name:"goca", exec:"/bin/goca")!
	r.add_zinit_cmd(name:"redis", exec:"redis-server --port 7777", test:"redis-cli -p 7777 PING")!
	r.add_zinit_cmd(name:"redis2", exec:"redis-server --port 7778")!

	r.build(args.reset)!
}

```

when we start the docker this 3 services should be running

more info how to use see https://github.com/threefoldtech/zinit/tree/master/docs

not implemented

- ENV, because docker has this already
- LOG: is default to ring (which means you need to use '''zinit log''' to see it)


### multi line commands

special: the cmd can be multiline, if thats the case then a executable file will be created and zinit will launch that one, only bash files supported

```golang
r.add_zinit_cmd(name:"goca", 
		exec:'
			mkdir -p /goca/data
			cd /goca/data
			/bin/goca
		')!
```

- if no `set -ex` or simular at 1nd line then will add one (this to make sure the script dies if some error happens inside)

