module terraform

import redisclient
import os

[heap]
struct TerraformFactory {
mut:
	instances    map[string]&TerraformInstance
}

enum TerraformInstanceStatus {
	init
	ok
	error
}


[heap]
struct TerraformInstance {
pub mut:
	path string
	status TerraformInstanceStatus
}


//needed to get singleton
fn init2() TerraformFactory {
	mut f := terraform.TerraformFactory{
	}	
	return f
}


//singleton creation
const factory = init2()

//make sure to use new first, so that the connection has been initted
//then you can get it everywhere
pub fn get(name string) ?&TerraformInstance {
	mut f := terraform.factory
	if ! (name in f.instances){
		f.instances[name] = &TerraformInstance{path:"~/terraform/${name}"}
	}
	mut i := f.instances[name]
	if i.status == TerraformInstanceStatus.error{
		return error("$i is in error, cannot get terraform instance.")
	}
	if i.status  == TerraformInstanceStatus.init{
		if i.path.contains("~"){
			home := os.real_path(os.environ()["HOME"])
			i.path = i.path.replace("~",home)
		}
		if ! os.exists(i.path){
			os.mkdir_all(i.path)?
		}
		i.status = TerraformInstanceStatus.ok
	}
	//download: https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.2_linux_amd64.zip 
	
	return i
}



// fn (mut h TerraformFactory) post_json_str(prefix string, postdata string, cache bool, authenticated bool) ?string {
// 	return result
// }
