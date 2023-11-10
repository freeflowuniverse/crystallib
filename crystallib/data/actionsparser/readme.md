# 3script

is our small language which allows us to execute actions

## actions

are text based representatsions of actions which need to be executed

example

```
!!tflibrary.circlesmanager.circle_add 
    gitsource:'books'
    path:'technology/src'
    name:technology
```

the first one is the action, the rest are the params


## to select cid, actor or circle

```go
!!select_cid core
!!select_circle aaa
!!select_actor people
```

Depending specified cid or circle or actor, we make a default selection

## way how to use for a module

The idea is we can use 3script (our actions script) to do things with a module

The generic actions()... is used to make all happen.


```go
import freeflowuniverse.crystallib.data.actionsparser

// !!hr.employee_define
//     descr:'Junior Engineer'
//     growth:'1:5,60:30' cost:'4000USD' indexation:'5%'
//     department:'engineering'

pub actions(actions actionsparser.Actions) ! {
    
    mut bizmodel:=...
    bizmodel.hr_actions(actions actionsparser.Actions)!

}

// populate the params for hr
fn (mut m BizModel) hr_actions(actions actionsparser.Actions) ! {
	mut actions2 := actions.filtersort(actor: 'hr')!
	for action in actions2 {
		if action.name == 'employee_define' {
			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!
            //...
        }
    }
}
```
