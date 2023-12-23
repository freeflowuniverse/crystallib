# Play

## play.session

**The PlayArgs:**

- script3 string
- actions playbook.PlayBook
- context ?&Context
- session ?&Session
- context_name string = "default"
- sid string
- coderoot string
- interactive bool
- fsdb_encrypted bool
- action_name  string //to filter actions (optional)
- action_actor string //to filter actions (optional)
- action_priorities []string //form of 'actorname:actionname' or 'actorname'	
- action_filter []string //same as priorities but will remove all the ones who don't match in the filter statements

```v
import freeflowuniverse.crystallib.core.play

mut session:=play.session_new(
    context:context
    sid:'mysession
    action_filter:["git","someactor:someactionname"]
)!

for action in session.actions.actions{
    if action.name=='something'{
    }
}

```

## how to use it 

example how to use the play in a module, this is how actions get executed

```v
module doctree


pub fn play(args play.PlayArgs) ! {

	mut session:=play.session(args)!
	for action in session.actions.find(filter:["doctree","otheractor:add"]) {
		mut p:=action.params
		match action.name {
			'playbooks_scan' {
				// playbooks_scan(p)!
				panic("implement")
			}
			else {
				return error('action name ${action.name} not supported')
			}
		}
	}
}

```v

chech in params how to get values from params

## 3script

### for context, coderoot and snippet

```js

!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true coderoot:'~/hero/code'

!!core.coderoot_set coderoot:'~/hero/code'

!!core.snippet name:codeargs pull:true reset:false

//sets the params in current session
!!core.params_session_set
	param1:'111'
	param2:'222'

!!core.params_context_set
	param1:'111'
	param2:'222'


```

# Context

is a context which is passed when executing wal actions

```v


// cid          string = "000" // rid.cid or cid allone
// name         string // a unique name in cid
// params       string
// coderoot	 string
// interactive  bool
// fsdb_encrypted bool	
// script3      string //if context is created from a 3script

mut context:=context.new(name:'mycontext',coderoot:'/tmp/code',interactive:true,fsdb_encrypted:true)!

// uid	string //unique id
// name string
// start string  //can be e.g. +1h
// ```
context.session_new(name:'mysession')!

```

## 3script

```js
!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true

!!core.coderoot_set '~/hero/code'

!!core.snippet codeargs coderoot'~/hero/code' pull:true reset:false

```

