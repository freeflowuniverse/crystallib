## play.session

```js
name                string // unique id for session (session id), can be more than one per context
plbook              playbook.PlayBook //is how heroscripts are being executed
interactive         bool = true
params              paramsparser.Params
start               ourtime.OurTime
end                 ourtime.OurTime
context             Context        //link back to the context
```

### **The PlayArgs:**

- context             ?&Context   
- session             ?&Session   
- context_name        string = 'default'
- session_name        string        //default will be based on a date when run
- interactive         bool = true   //can ask questions, default on true
- coderoot            string        //this will define where all code is checked out
- playbook_url        string        //url of heroscript to get and execute in current context
- playbook_path       string        //path of heroscript to get and execute
- playbook_text       string        //heroscript to execute

```golang
import freeflowuniverse.crystallib.core.base
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


### use playbook

```golang

// add playbook heroscript (starting from path, text or git url)
//```
// path    string
// text    string
// prio    int = 99
// url     string
//```	
fn (mut session Session) playbook_add(args_ PLayBookAddArgs) !

//show the sesstion playbook as heroscript
fn (mut session Session) heroscript()

// add priorities for the playbook, normally more internal per module
fn (mut self Session) playbook_priorities_add(prios map[int]string)


```

### use the kvs database

is stored on filesystem

```golang

// get db of the session, is unique per session
fn (mut self Session) db_get() !dbfs.DB {

// get the db of the config, is unique per context
fn (mut self Session) db_config_get() !dbfs.DB {

```