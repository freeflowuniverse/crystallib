module terraform
import os

enum TerraformDeploymentStatus {
	init
	ok
	error
}



[heap]
struct TerraformDeployment {
pub mut:
	name string
	path string
	status TerraformDeploymentStatus
}


//if path is empty then will put the directory under ~/terraform
pub fn (mut f TerraformFactory) new(name string,path_ string) ?&TerraformDeployment {

	if name in f.deployments{
		return f.deployments[name]
	}

	mut path := path_
	if path.contains("~"){
		home := os.real_path(os.environ()["HOME"])
		path = path.replace("~",home)
	}

	f.deployments[name] = &TerraformDeployment{name:name, path:path}

	return f.deployments[name]

}

pub fn (mut f TerraformFactory)  get(name string) ?&TerraformDeployment {

	if ! (name in f.deployments){
		return error("cannot find terraform deployment with name $name")
	}
	mut i := f.deployments[name]
	if i.status == TerraformDeploymentStatus.error{
		return error("$i is in error, cannot get terraform deployment $name")
	}
	
	return i
}