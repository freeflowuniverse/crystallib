module tfgridclient
import freeflowuniverse.crystallib.data.paramsparser


pub const version = '1.0.0'
const singleton = true
const default = true


const heroscript_default = "
!!tfdeployer.configure
    sshkey: ''
    mnemonic: ''
    network:'main'
"

pub enum Network {
    dev
    main
    test
}


//THIS THE THE SOURCE OF THE INFORMATION OF THIS FILE, HERE WE HAVE THE CONFIG OBJECT CONFIGURED AND MODELLED
pub struct TFGridClient {
pub mut:
    name string = 'default'
    ssh_key   string
    mnemonic string
    network  Network
}


fn (mut self TFGridClient) deployment_get(name string)!TFDeployment {
    mut d:=TFDeployment{}
    d.load()!
    return d
}


fn cfg_play(p paramsparser.Params) ! {
    network_str := p.get_default('network', 'main')!
    network := match network_str {
        'dev' { Network.dev }
        'test' { Network.test }
        else { Network.main }
    }

    mut mycfg := TFDeployment{
        sshkey: p.get_default('sshkey', '')!
        mnemonic: p.get_default('mnemonic', '')!
        network: network
    }
    set(mycfg)!
}