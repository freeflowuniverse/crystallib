# Play

## play.session

**The PlayArgs:**

- context             ?&Context      @[skip; str: skip]
- session             ?&Session      @[skip; str: skip]
- context_name        string = 'default'
- session_name        string //default will be based on a date when run
- interactive         bool = true //can ask questions, default on true
- coderoot            string //this will define where all code is checked out
- playbook_url                 string //url of heroscript to get and execute in current context
- playbook_path                string //path of heroscript to get and execute
- playbook_text                string //heroscript to execute

```v
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.develop.gittools

mut session:=play.session_new(
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

## heroscript

### for context, coderoot and snippet

```js

!!core.context_set name:'mybooks' cid:'000' interactive:false coderoot:'~/hero/code'

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

is a context which is passed when executing wal actions, is created automatically when creating session above

```v


mut context:=context.new(name:'mycontext',coderoot:'/tmp/code',interactive:true)!

// uid	string //unique id
// name string
// start string  //can be e.g. +1h
// ```
context.session_new(name:'mysession')!

```

## heroscript

```js
!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true

!!core.coderoot_set '~/hero/code'

!!core.snippet codeargs coderoot'~/hero/code' pull:true reset:false

```

> TODO: is this still correct?

