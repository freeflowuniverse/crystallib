# heroscript

is our small language which allows us to execute parser


## parser

are text based representatsions of parser which need to be executed

example

```js
!!tflibrary.circlesmanager.circle_add 
    gitsource:'books'
    path:'technology/src'
    name:technology
```

the first one is the action, the rest are the params

```v
import freeflowuniverse.crystallib.core.playbook
mut plbook := playbook.new(text: "....") or { panic(err) }

//path    string
//text    string
//url     sstring
//prio    int   = 99
plbook.add(path:...)!

```


Depending specified cid or circle or actor, we make a default selection

## way how to use for a module

The idea is we can use heroscript (our parser script) to do things with a module

The generic parser()... is used to make all happen.


```go
import freeflowuniverse.crystallib.core.playbook

// !!hr.employee_define
//     descr:'Junior Engineer'
//     growth:'1:5,60:30' cost:'4000USD' indexation:'5%'
//     department:'engineering'


// populate the params for hr
fn (mut m BizModel) hr_actions(actions playbook.PlayBook) ! {
	mut actions2 := actions.find('hr.*,vm.start')!
	for action in actions2 {
		if action.name == 'employee_define' {
			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!
            //...
        }
    }
}
```
