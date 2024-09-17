module tfgrid3deployer

import freeflowuniverse.crystallib.threefold.grid.models as grid_models
import freeflowuniverse.crystallib.threefold.grid
import freeflowuniverse.crystallib.data.encoder
import freeflowuniverse.crystallib.ui.console
import encoding.base64
import os
import compress.zlib
import encoding.hex
import x.crypto.chacha20
import crypto.sha256
import rand


@[heap]
pub struct TFDeployment {
pub mut:
    name        string
    description string
    vms         []VMachine
    zdbs        []ZDB
    webnames    []WebName
    network     ?NetworkSpecs
mut:
    deployer    grid.Deployer   @[skip; str: skip]
    kvstore     KVStoreFS       @[skip; str: skip]
}
 
pub fn new_deployment(name string) !TFDeployment {
    mut grid_client := get()!

    network := match grid_client.network {
        .dev { grid.ChainNetwork.dev }
        .qa { grid.ChainNetwork.qa }
        .test { grid.ChainNetwork.test }
        .main { grid.ChainNetwork.main }
    }

    deployer := grid.new_deployer(grid_client.mnemonic, network)!

    return TFDeployment{
        name: name
        deployer: deployer
        kvstore: KVStoreFS{}
    }
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

pub fn (mut self TFDeployment) vm_get(vm_name string)! VMachine {
    d := self.load()!
    println("d = ${d}")
    // return d.vms
    // Placeholder to change this later to return only vm.
    return VMachine{}
}

pub fn (mut self TFDeployment) load()! TFDeployment {
    value := self.kvstore.get(self.name)!
    decrypted := self.decrypt(value)!
    decompressed := self.decompress(decrypted)!
    decoded := self.decode(decompressed)!
    return decoded
}

fn (mut self TFDeployment) save()!{
    encoded_data := self.encode()!
    self.kvstore.set(self.name, encoded_data)!
}

fn (self TFDeployment) compress(data []u8) ![]u8 {
    return zlib.compress(data) or { error("Cannot compress the data due to: ${err}") }
}

fn (self TFDeployment) decompress(data []u8) ![]u8 {
    return zlib.decompress(data) or { error("Cannot decompress the data due to: ${err}") }
}

fn (self TFDeployment) encrypt(compressed []u8) ![]u8 {
    key_hashed := sha256.hexhash(self.deployer.mnemonics)
    name_hashed := sha256.hexhash(self.name)
    key := hex.decode(key_hashed)!
    nonce := hex.decode(name_hashed)![..12]
    encrypted := chacha20.encrypt(key, nonce, compressed) or { return error("Cannot encrypt the data due to: ${err}") }
    return encrypted
}

fn (self TFDeployment) decrypt(data []u8) ![]u8 {
    key_hashed := sha256.hexhash(self.deployer.mnemonics)
    name_hashed := sha256.hexhash(self.name)
    key := hex.decode(key_hashed)!
    nonce := hex.decode(name_hashed)![..12]

    compressed := chacha20.decrypt(key, nonce, data) or { return error("Cannot decrypt the data due to: ${err}") }
    return compressed
}

fn (self TFDeployment) encode() ![]u8 {
    mut b := encoder.new()
    b.add_string(self.name)
    b.add_int(self.vms.len)

    for vm in self.vms {
        vm_data := vm.encode()!
        b.add_int(vm_data.len)
        b.add_bytes(vm_data)
        // zd.encode()
        // k8s.encode() ...etc
    }

    compressed := self.compress(b.data)!
    encrypted := self.encrypt(compressed)!
    return encrypted
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
