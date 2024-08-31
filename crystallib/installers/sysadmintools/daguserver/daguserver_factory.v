
module daguserver


__global (
	daguserver_global map[string]&DaguCFG
	daguserver_default string = "default"
)

/////////FACTORY

pub fn get() !&DaguCFG {
	mut args := args_
	name := "default"
	if !(name in daguserver_global) {
		set(args_)!
	}
	return daguserver_global[name] or { panic("bug") }
}

//switch instance to be used for daguserver
pub fn switch(name string) {
	daguserver_default = name
}


pub fn config_new()! {

}

pub fn config_save()! {

}


fn set(obj DaguCFG)! {
	mut obj := args.cfg or {
			DaguCFG{
				name:name
			}			
		}
	obj.load()!
	daguserver_global[obj.name] = &obj
}


