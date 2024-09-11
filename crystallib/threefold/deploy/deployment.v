module deploy

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.threefold.grid

pub const version = '1.14.3'
const singleton = true
const default = true



@[heap]
pub struct TFDeployment {
pub mut:
    name     string = 'default'
    description string
    vms []VMachine
    // zdbs  //TODO
    // webgw     
mut:
    deployer	  ?grid.Deployer
}

fn (mut self TFDeployment) deployer() !grid.Deployer {
    return self.deployer or {
        //logger.debug('Initializing Deployer instance')
        mut grid_client := get()!
        network := match grid_client.network{
            .dev { grid.ChainNetwork.dev }
            .qa { grid.ChainNetwork.qa }
            .test {
                return grid.ChainNetwork.test
            }
            .main {
                return grid.ChainNetwork.main
            }
        }
        self.deployer =  grid.new_deployer(grid_client.mnemonic, grid_client.network)!        
        self.deployer
    }
}


//gets the info from the TFGrid
fn (mut self TFDeployment) load()! {
    //TODO: load the metadata from TFGrid and populate the TFDeployment ((ssh_key))
    mut grid_client := get()!
}

fn (mut self TFDeployment) save()! {
    //TODO: save info to the TFChain, encrypt with mnemonic (griddriver should do this)
}



pub fn (mut self TFDeployment) vm_deploy(args_ VMRequirements)!VMachine {
    //TODO: check vm already exists on the grid, if yes fail

}

pub fn (mut self TFDeployment) vm_get(name string)!VMachine {
    //TODO: check vm already exists if not fail
    //TODO: load the metadata from the VM, populater a VMachine

    //the name on TFChain is $deploymentname__$name

}

pub fn (mut self TFDeployment) vm_delete(name string)!VMachine {
    //TODO: check vm already exists if not fail
    //TODO: load the metadata from the VM, populater a VMachine

    //the name on TFChain is $deploymentname__$name

}


pub fn (mut self TFDeployment) vm_list()![]string {
    //list names of vm's we have for this deployment
}



fn (self TFDeployment) encode() ![]u8 {
	mut b := encoder.new()
    //encode what is required on TFDeployment level
    b.add_string(self.name)
	for vm in self.vms{
        data:=vm.encode()!
        b.add_int(v.data.len)
        b.add_bytes(data)        
    }
}

