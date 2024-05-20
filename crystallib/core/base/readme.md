## context & sessions

Everything we do in hero lives in a context, each context has a unique name.

Redis is used to manage the contexts and the sessions.

- redis db 0
    - `context:current` curent id of the context, is also the DB if redis if redis is used
- redis db X, x is nr of context
    - `context:name` name of this context
    - `context:secret` secret as is used in context (is md5 of original config secret)
    - `context:privkey` secp256k1 privkey as is used in context (encrypted by secret)
    - `context:params` params for a context, can have metadata
    - `context:lastid` last id for our db
    - `session:$id` the location of session
        - `session:$id:params` params for the session, can have metadata

Session id is $contextid:$sessionid  (e.g. 10:111)

**The SessionNewArgs:**

- context_name        string = 'default'
- session_name        string        //default will be an incremental nr if not filled in
- interactive         bool = true   //can ask questions, default on true
- coderoot            string        //this will define where all code is checked out

```v
import freeflowuniverse.crystallib.core.base

mut session:=context_new(
    coderoot:'/tmp/code'
    interactive:true
)!

mut session:=session_new(context:'default',session:'mysession1')!
mut session:=session_new()! //returns default context & incremental new session

```

