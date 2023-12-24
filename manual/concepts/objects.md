

## rootobject with config

example of 3 methods each of such rootobjects need to have

```golang

pub fn (mut c Context) str() string {
	return c.script3() or {"BUG: can't represent the object properly, I try raw.\n$c"}
}

fn (mut c Context) str2() string {
	return "cid:${c.cid} name:${c.name} " or {"BUG: can't represent the context properly, I try raw"}
}

//if executed needs to redefine this object
pub fn (mut c Context) script3() !string {
	mut out:="!!core.context_define ${c.str2()}\n"
	mut params:=c.params()!
	if ! params.empty(){
		out+="\n!!core.context_params guid:${c.guid()}\n"
		out+=params.script3()+"\n"
	}
	return out
}

//needs to be unique for universe
pub fn (mut c Context) guid() string {
	return "${c.cid}:${c.name}"
}
```