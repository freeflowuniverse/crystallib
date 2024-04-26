## base session

**The SessionNewArgs:**

- context             ?&Context   
- session             ?&Session   
- context_name        string = 'default'
- session_name        string        //default will be based on a date when run
- interactive         bool = true   //can ask questions, default on true
- coderoot            string        //this will define where all code is checked out

```v
import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.develop.gittools

mut session:=base.session_new(
    coderoot:'/tmp/code'
    interactive:true
)!
```

