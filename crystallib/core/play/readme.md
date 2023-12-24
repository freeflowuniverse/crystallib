# Play

## play.session

**The PlayArgs:**

- script3           string
- plbook            playbook.PlayBook
- context           ?&Context
- session           ?&Session
- context_name      string = 'default'
- session_name      string
- coderoot          string
- interactive       bool
- fsdb_encrypted    bool
- playbook_priorities  map[int]string //filter and give priority
- playbook_core_execute bool = true //executes ssh & git actions

```v
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.osal.gittools

mut session:=play.session_new(
    context_name:'default'
    session_name:''
    coderoot:'/tmp/code'
    interactive:true
)!

//THE next could be in a module which we call

pub fn play_git(mut session Session) ! {
	for mut action in session.plbook.find(filter:'gittools.*')! {
		mut p := action.params
		mut repo := p.get_default('repo', '')!
        ... do whatever is required to 
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

