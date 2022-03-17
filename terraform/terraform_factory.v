module terraform

import builder
import os
import crypto.md5
import despiegk.crystallib.redisclient
import freeflowuniverse.crystallib.rootpath

pub enum TerraformFactoryStatus {
	init
	ok
	error
}



struct TerraformFactory {
mut:
	deployments    	map[string]&TerraformDeployment
	status		 	TerraformFactoryStatus
	redis  			&redisclient.Redis	
pub mut:
	tf_cmd			string
}


//needed to get singleton
fn init2() TerraformFactory {
	mut x := terraform.TerraformFactory{
		redis: redisclient.get_unixsocket_new_default() or { panic(err) }
	}
	return x
}


//singleton creation
const factory = init2()

pub fn get() ?&TerraformFactory {

	mut f_ := terraform.factory
	// home_ := os.real_path(os.home_dir())
	// f_.tf_cmd = "$home_/git3/bin/terraform"
	f_.tf_cmd = rootpath.default_prefix("/bin/terraform")


	if f_.status  == TerraformFactoryStatus.init{
		if ! os.exists(f_.tf_cmd){
			mut a := terraform.factory
			home := os.real_path(os.home_dir())
			// a.tf_cmd = "$home/git3/bin/terraform"
			a.tf_cmd = rootpath.default_prefix("/bin/terraform")

			mut n := builder.node_local()?
			mut url:=""
			if n.platform == builder.PlatformType.osx{
				if n.cputype == builder.CPUType.arm{
					url = "https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.4_darwin_arm64.zip"
				}else{
					url = "https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_darwin_amd64.zip"
				}
			}else if n.platform == builder.PlatformType.ubuntu{
				url = "https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip"
			}else{
				return error("platform not supported to install terraform")
			}

			mut cmd := $tmpl("install_terraform.sh")
			println(cmd)

			n.exec(cmd:cmd, reset:true, description:"install terraform ; echo ok",stdout:true) or {
				return error("cannot install terraform\n"+err.msg()+"\noriginal cmd:\n${cmd}")
			}
		}

		f_.status = TerraformFactoryStatus.ok
	}
	return &f_
}


//initialize terraform
fn (mut tff TerraformFactory) tf_inialize(dir_path string) ? {
	mut node := builder.node_local()?
	if ! os.exists("$dir_path/.terraform"){
		node.exec(cmd:"cd $dir_path && ${tff.tf_cmd} init",reset:true)?
	}
}

//execute terraform
fn (mut tff TerraformFactory) tf_execute(dir_path string) ? {
	tff.tf_inialize(dir_path)?	
	mut tohash := ""
	res := os.ls(dir_path) ?
	for file in res {
		filepath:="$dir_path/$file"
		if !os.is_file(filepath) {
			continue
		}
		if !filepath.ends_with(".tf") {
			continue
		}
		mut fc := os.read_file(filepath)?
		fc = fc.trim_space()
		tohash+=fc
	}
	hhash := md5.hexhash(tohash)
	hhash_check := "${dir_path}__tfexec_${hhash}"
	mut node := builder.node_local()?
	if ! node.done_exists(hhash_check){
		node.exec(cmd:"cd $dir_path && ${tff.tf_cmd} apply -parallelism=1 -auto-approve",reset:true)?
		node.done_set(hhash_check,"OK")?
	}
}


//destroy terraform
fn (mut tff TerraformFactory) tf_destroy(dir_path string) ? {
	tff.tf_inialize(dir_path)?	
	mut node := builder.node_local()?
	node.exec(cmd:"cd $dir_path && ${tff.tf_cmd} destroy -parallelism=1 -auto-approve",reset:true)?
}


