# silence

the following code shows how we can surpress all output, errors should still go to stderr (to be tested)

the example is a .vsh script note the arguments to v, this also makes sure there are no notices shown.

```go
#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console

console.silent_set()
mut job2 := osal.exec(cmd: 'ls /',debug:true)!
println("I got nothing above")

console.silent_unset()
println("now I will get output")

osal.exec(cmd: 'ls /',debug:true)!
```