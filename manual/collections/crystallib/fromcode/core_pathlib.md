# pathlib.

Is a generic way how to work with paths.

```golang
import freeflowuniverse.crystallib.core.pathlib

mut p:=pathlib.get("adir")! 

p.is_dir()

```

## pathlib

a flexible way how to find files.

```golang
import freeflowuniverse.crystallib.core.pathlib

mut p:=pathlib.get("/tmp/mysourcefiles")! 

mut pathlist:=p.list(regex:[r'.*.md$'])! //this gets all files ending on .md
pathlist.copy("/tmp/mydest")!

```

# Library: