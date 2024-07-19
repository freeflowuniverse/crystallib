## 2 phase , make smaller containers

```golang
module goca

import freeflowuniverse.crystallib.virt.docker
import threefoldtech.vbuilder.core.gobuilder

pub fn build(args docker.BuildArgs) ! {
	mut engine := args.engine
	
	// make sure dependency has been build
	gobuilder.build(engine: engine, reset: args.reset, strict: args.strict)!

	// specify we want to build an alpine version
	mut r := engine.recipe_new(name: 'goca', platform: .alpine)

	r.add_from(image: 'gobuilder', alias: 'builder')!

	//HERE IS PHASE 1 , A LOT IS HAPPENING

	r.add_from(image: 'base', alias: 'installer')!
    // we are now in phase 2, and start from a clean image, we call this layer 'installer'
    //we now add the file as has been build in step one to phase 2
	r.add_copy(from:"builder", source:"/bin/goca", dest:"/bin/goca")!

	r.add_env('CAPATH' ,'/goca/data')!
	r.add_workdir(workdir:"/goca/data")!
	r.add_expose(ports:['80'])!

	r.add_zinit_cmd(name:"goca", exec:"/bin/goca")!

	r.build(args.reset)!
}

```

now the resulting docker image will be much smaller because we had a 2nd layer

