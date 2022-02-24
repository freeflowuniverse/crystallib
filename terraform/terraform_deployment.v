module terraform
import os
import crypto.md5
import freeflowuniverse.crystallib.rootpath
import threefoldtech.vgrid.gridproxy
import threefoldtech.vgrid.explorer

enum TerraformDeploymentStatus {
	init
	ok
	error
}

pub enum TFGridNet{
	main
	test
	dev
}


pub struct TerraformDeploymentArgs {
pub mut:
	name 		string
	mnemonic 	string
	tfgridnet 	TFGridNet
	guid		string
	sshkey 		string
}

[heap]
struct TerraformDeployment {
pub:
	name 		string
	path 		string
	mnemonic 	string
	sshkey 		string
	guid 		string
pub mut:
	status 		TerraformDeploymentStatus
	vms 		[]TFVM
	network 	TFNet
	tfgridnet	TFGridNet //test, main or dev
}


//will put under ~/git3/terraform/$name
pub fn (mut f TerraformFactory) deployment_get(args_ TerraformDeploymentArgs) ?&TerraformDeployment {

	mut args := args_

	if args.sshkey == "" {
		if ! ("TFGRID_SSHKEY" in os.environ()){
			return error("Cannot continue, do 'export TFGRID_SSHKEY=...' ")
		}
		args.sshkey = os.environ()["TFGRID_SSHKEY"].trim_space()
	}
	args.guid = md5.hexhash(args.mnemonic).substr(0,8) //create unique id


	if args.mnemonic == "" {
		if ! ("TFGRID_MNEMONIC" in os.environ()){
			return error("Cannot continue, do 'export TFGRID_MNEMONIC=...' ")
		}
		args.mnemonic = os.environ()["TFGRID_MNEMONIC"].trim_space()
	}
	args.guid = md5.hexhash(args.mnemonic).substr(0,8) //create unique id

	if args.name == ""{
		return error ("specify name for deployment")
	}

	if args.name in f.deployments{
		return f.deployments[args.name]
	}

	mut path := rootpath.default_prefix("/terraform/$args.name")

	f.deployments[args.name] = &TerraformDeployment{
			name:args.name, 
			path:path,
			mnemonic:args.mnemonic,
			tfgridnet:args.tfgridnet
			sshkey:args.sshkey, 
			guid:args.guid
		}

	if ! os.exists(path){
		os.mkdir_all(path)?	
	}

	return f.deployments[args.name]

}



//execute all available terraform objects
pub fn (mut tfd TerraformDeployment) deploy() ? {	
	mut tff := get()?
	tfd.network.write(mut &tfd)?
	for mut vm in tfd.vms{
		vm.write(mut &tfd)?
	}
	tff.tf_execute(tfd.path)?
}

//execute all available terraform objects
pub fn (mut tfd TerraformDeployment) destroy() ? {	
	mut tff := get()?
	tff.tf_destroy(tfd.path)?
}

//return which net in string form
pub fn (mut tfd TerraformDeployment) tfgrid_net_string() string {	
	return match tfd.tfgridnet {
		.main { 'main' }
		.test { 'test' } 
		.dev { 'dev' }
	}	
}


//retrieve a gridproxy starting from terraform deployment
pub fn (mut tfd TerraformDeployment) gridproxy() &gridproxy.GridproxyConnection {

	net2 := match tfd.tfgridnet {
		.main { gridproxy.TFGridNet.main }
		.test { gridproxy.TFGridNet.test } 
		.dev { gridproxy.TFGridNet.dev }
	}	

	mut gp := gridproxy.get(net2)

	return gp
	
}

//retrieve right explorer starting from terraform deployment
pub fn (mut tfd TerraformDeployment) explorer() &explorer.ExplorerConnection {

	net2 := match tfd.tfgridnet {
		.main { explorer.TFGridNet.main }
		.test { explorer.TFGridNet.test } 
		.dev { explorer.TFGridNet.dev }
	}	

	mut explorer := explorer.get(net2)

	return explorer
	
}
