module terraform

import builder
import os

enum TerraformFactoryStatus {
	init
	ok
	error
}


[heap]
struct TerraformFactory {
pub mut:
	deployments    map[string]&TerraformDeployment
	status		 TerraformFactoryStatus
}



//needed to get singleton
fn init2() &TerraformFactory {
	mut f := terraform.TerraformFactory{}	
	return &f
}


//singleton creation
const factory = init2()

pub fn get() ?&TerraformFactory {

	mut f := terraform.factory

	home2 := os.real_path(os.environ()["HOME"])

	if f.status  == TerraformFactoryStatus.init{
		mut n := builder.node_local()?
		if ! os.exists("$home2/git3/terraform"){
			mut url:=""
			if n.platform == builder.PlatformType.osx{
				if n.cputype == builder.CPUType.arm{
					url = "https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.4_linux_amd64.zip"
				}else{
					url = "https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_darwin_amd64.zip"
				}
			}else if n.platform == builder.PlatformType.ubuntu{
				url = "https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip"
			}else{
				return error("platform not supported to install terraform")
			}

			home := os.real_path(os.environ()["HOME"])

			mut cmd := $tmpl("install_terraform.sh")
			println(cmd)

			n.exec(cmd:cmd, period:0, reset:true, description:"install terraform",stdout:true,checkkey:"terraforminstall") or {
				return error("cannot install terraform\n"+err.msg+"\noriginal cmd:\n${cmd}")
			}
		
		}
		f.status = TerraformFactoryStatus.ok
	}	
	return f
}

