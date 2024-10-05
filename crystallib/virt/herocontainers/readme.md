
# Herocontainers

Tools to work with containers

```go
#!/usr/bin/env -S  v -n -cg -w -enable-globals run

import freeflowuniverse.crystallib.virt.herocontainers
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.builder

//interative means will ask for login/passwd

console.print_header("BUILDAH Demo.")

//if herocompile on, then will forced compile hero, which might be needed in debug mode for hero 
// to execute hero scripts inside build container
mut pm:=herocontainers.new(herocompile=true)!
//mut b:=pm.builder_new(name:"test")!

//create 
pm.builderv_create()!

//get the container
//mut b2:=pm.builder_get("builderv")!
//b2.shell()!


```

## buildah tricks

```bash
#find the containers as have been build, these are the active ones you can work with
buildah ls
#see the images
buildah images
```

result is something like


```bash
CONTAINER ID  BUILDER  IMAGE ID     IMAGE NAME                       CONTAINER NAME
a9946633d4e7     *                  scratch                          base
86ff0deb00bf     *     4feda76296d6 localhost/builder:latest         base_go_rust
```

some tricks

```bash
#run interactive in one (here we chose the builderv one)
buildah run --terminal --env TERM=xterm base /bin/bash
#or
buildah run --terminal --env TERM=xterm default /bin/bash
#or
buildah run --terminal --env TERM=xterm base_go_rust /bin/bash

```

to check inside the container about diskusage

```bash
pacman -Su ncdu
ncdu
```


## future

should make this module compatible with https://github.com/containerd/nerdctl