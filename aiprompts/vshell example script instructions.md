
# how to run the vshell example scripts

this is how we want example scripts to be, see the first line

```vlang
#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.installers.sysadmintools.daguserver

mut ds := daguserver.get()!

println(ds)
```

the files are in ~/github/freeflowuniverse/crystallib/examples for crystallib

## important instructions

- never use fn main() in a .vsh script

