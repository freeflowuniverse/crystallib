# Base

Clients, DALs, SAL's can inherit base


```golang

pub struct Base {
pub mut:
	session_ ?&Session 
	instance    string
}

//how to use

import freeflowuniverse.crystallib.core.play

pub struct B2Client {
	play.Base
pub mut:
	someprop string
}



```

## Base Methods

This will give some super powers to each base inheritted class


```golang

// return a session which has link to the actions and params on context and session level
// the session also has link to fskvs (filesystem key val stor and gitstructure if relevant)
//```
// context             ?&Context      @[skip; str: skip]
// session             ?&Session      @[skip; str: skip]
// context_name        string = 'default'
// session_name        string //default will be based on a date when run
// interactive         bool = true //can ask questions, default on true
// coderoot            string //this will define where all code is checked out
// playbook_url                 string //url of heroscript to get and execute in current context
// playbook_path                string //path of heroscript to get and execute
// playbook_text                string //heroscript to execute
//```
pub fn (mut self Base) session_set(args_ PlayArgs) !&Session 

pub fn (mut self Base) session() !&Session

pub fn (mut self Base) context() !&Context


```