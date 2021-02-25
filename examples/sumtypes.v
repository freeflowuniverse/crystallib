//an example about an executor class (which executes on a local system or over ssh)

//the local one
struct ExecutorLocal {
	pub mut:
	name string = "local"
}

//can execute remote, need to have addr & port
struct ExecutorSSH {
	addr string
	port int = 22
	name string = "ssh"
}


fn (e ExecutorLocal) name_get() string {
	return e.name
}

fn (e ExecutorSSH) name_get() string {
	return e.name
}


//executor can be one of both
type Executor = ExecutorLocal | ExecutorSSH

struct Builder{
	executor Executor
}

fn (mut b Builder) name_get() string {
	 match b.executor {
        ExecutorSSH { return b.executor.name_get() }
        ExecutorLocal { return b.executor.name_get() }
    }

}

struct BuilderArguments{
	addr string
	port int
}

//the factory which returns an executor, based on the arguments will chose one type or the other
fn get (arg BuilderArguments) Builder {
	if arg.addr == "" {
		return Builder{executor:ExecutorLocal{}}
	}else{
		return Builder{executor:ExecutorSSH{addr:arg.addr,port:arg.port}}
	}
}



mut b1 := get({addr:"127.0.0.1"})
println(b1)
println(b1.name_get())

//OUTPUTS:
// Builder{
//     executor: Executor(ExecutorSSH{
//         addr: '127.0.0.1'
//         port: 0
//         name: 'ssh'
//     })
// }
// ssh

//will be local executor because addr not given
mut b2 := get({})
println(b2)
println(b2.name_get())

//OUTPUTS:
// Builder{
//     executor: Executor(ExecutorLocal{
//         name: 'local'
//     })
// }
// local

