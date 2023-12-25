module lima
import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal

[params]
pub struct VMNewArgs {
pub mut:	
    name           string = "default"
    cpus           int = 5
    memory         i64 = 1000 //in MB
    disk           i64 = 20000 //in MB
    reset bool
    start       bool = true
}
pub fn vm_new(args VMNewArgs) !{

    if args.reset{
        vm_delete(args.name)!
    }else{
        return error("can't create vm, does already exist.")
    }

    ymlfile:=pathlib.get_file(path:"${os.home_dir()}/.lima/${args.name}_ours.yaml",create:true)!
	mut a := $tmpl('templates/alpine_v.yaml')

    memory2:=args.memory/1000

    pathlib.template_write(a, ymlfile.path,true)!

	cmd := 'limactl create --name=${args.name} --cpus=${args.cpus} --memory=${memory2} ${ymlfile.path}'
	osal.exec(cmd:cmd,stdout:true)!

    if args.start{
        cmd2 := 'limactl start ${args.name}'
        res2 := osal.exec(cmd:cmd2,stdout:true)!
    }

}




	
