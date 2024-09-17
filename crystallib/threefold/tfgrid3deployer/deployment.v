module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.data.encoder
import freeflowuniverse.crystallib.ui.console
import encoding.base64
import os

@[heap]
pub struct TFDeployment {
pub mut:
    name        string
    description string
    vms         []VMachine
    zdbs        []ZDB
    webnames    []WebName
mut:
    deployer    ?grid.Deployer  @[skip; str: skip]
}

fn (mut self TFDeployment) new_deployer() !grid.Deployer {
    if self.deployer == none {
        mut grid_client := get()!
        network := match grid_client.network {
            .dev { grid.ChainNetwork.dev }
            .test { grid.ChainNetwork.test }
            .main { grid.ChainNetwork.main }
            .qa { grid.ChainNetwork.qa }
        }
        self.deployer = grid.new_deployer(grid_client.mnemonic, network)!
    }
    return self.deployer or { return error('Deployer not initialized') }
}

fn create_signature_requirement(twin_id int) grid_models.SignatureRequirement {
    console.print_header('Setting signature requirement.')
    return grid_models.SignatureRequirement{
        weight_required: 1,
        requests: [
            grid_models.SignatureRequest{
                twin_id: u32(twin_id),
                weight: 1,
            },
        ],
    }
}

pub fn (mut self TFDeployment) vm_get(name string)! []VMachine {
    d := self.load(name)!
    return d.vms
}

pub fn (mut self TFDeployment) load(deployment_name string)! TFDeployment {
    path := "${os.home_dir()}/hero/var/tfgrid/deploy/"
    filepath := "${path}${deployment_name}"
    base64_string := os.read_file(filepath) or {
        return error("Failed to open file due to: ${err}")
    }
    bytes := base64.decode(base64_string)
    d := self.decode(bytes)!
    return d
}

fn (mut self TFDeployment) save()! {
    dir_path := "${os.home_dir()}/hero/var/tfgrid/deploy/"
    os.mkdir_all(dir_path)!
    file_path := dir_path + self.name

    encoded_data := self.encode() or {
        return error('Failed to encode deployment data: ${err}')
    }
    base64_string := base64.encode(encoded_data)

    os.write_file(file_path, base64_string) or {
        return error('Failed to write to file: ${err}')
    }
}

fn (self TFDeployment) encode() ![]u8 {
    mut b := encoder.new()
    b.add_string(self.name)
    b.add_int(self.vms.len)

    for vm in self.vms {
        vm_data := vm.encode()!
        b.add_int(vm_data.len)
        b.add_bytes(vm_data)
    }

    return b.data
}

fn (self TFDeployment) decode(data []u8) !TFDeployment {
    if data.len == 0 {
        return error("Data cannot be empty")
    }

    mut d := encoder.decoder_new(data)
    mut result := TFDeployment{
        name: d.get_string(),
    }

    num_vms := d.get_int()

    for _ in 0 .. num_vms {
        d.get_int()
        vm_data := d.get_bytes()
        //mut dd := encoder.decoder_new(vm_data)
        vm := decode_vmachine(vm_data)!
        result.vms << vm
    }

    //ZDB & NAMES

    return result
}
