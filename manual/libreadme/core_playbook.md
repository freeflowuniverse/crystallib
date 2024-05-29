# heroscript

is our small language which allows us to run parser


## execute a playbook

the following will load heroscript and execute

```v
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.playcmds

// path string
// text string
// git_url string
// git_pull bool
// git_branch string
// git_reset bool
// session  ?&base.Session      is optional
mut plbook := playbook.new(path: "....")!

//now we run all the commands as they are pre-defined in crystallib (herolib)
playcmds.run(mut plbook)!


```



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




mut plbook := playbook.new(text: "....")!

```
## way how to use for a module


```v
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


## we can also use the filtersort

```v

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.playcmds

mut plbook := playbook.new(path: "....") or { panic(err) }

// filter parser based on the criteria
//```
// string for filter is $actor:$action, ... name and globs are possible (*,?)
//
// struct FilterSortArgs
// 	 priorities  map[int]string //filter and give priority
//```
// the action_names or actor_names can be a glob in match_glob .
// see https://modules.vlang.io/index.html#string.match_glob .
// the highest priority will always be chosen . (it can be a match happens 2x)
// return  []Action
actions:=plbook.filtersort({
    5:"sshagent:*",
    10:"doctree:*",
    11:"mdbooks:*",
    12:"mdbook:*",
})!

//now process the actions if we want to do it ourselves
for a in actions{
    mut p := action.params
    mut repo := p.get_default('repo', '')!
    if p.exists('coderoot') {
        coderoot = p.get_path_create('coderoot')!
    }
}

```

