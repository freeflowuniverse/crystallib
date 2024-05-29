# how to sue the playcmds

```v
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.base

mut s:=base.session_new(
    coderoot:'/tmp/code'
    interactive:true
)!


// path string
// text string
// git_url string
// git_pull bool
// git_branch string
// git_reset bool
// execute bool = true
// session  ?&base.Session      is optional

mut plbook := playbook.new(text: "....",session:s) or { panic(err) }





```