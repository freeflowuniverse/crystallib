module zinit


__global (
	zinit_global shared map[string]&Zinit
)

@[params]
pub struct FactorySetGet{
	reset bool
	zinit ?Zinit
}

pub fn get(args_ FactorySetGet) !&Zinit {
	mut args := args_
	args.name = "default"
	rlock zinit_global {
		if !(args.name in zinit_global) {
			set(args_)!
		}
		return zinit_global[args.name] or { panic("bug") }
	}
	return error("cann't find zinit in globals:'${args.name}'")
}

pub fn set(args_ FactorySetGet)! {
	mut args := args_
	args.name = "default"
	mut obj := args.zinit or {
			Zinit{
				name:args.name
				path: pathlib.get_dir(path: '/etc/zinit', create: true)!
				pathcmds: pathlib.get_dir(path: '/etc/zinit/cmds', create: true)!
				pathtests: pathlib.get_dir(path: '/etc/zinit/tests', create: true)!
			}			
		}
	obj.load()!
	lock zinit_global {
		zinit_global[obj.name] = &obj
	}
}


