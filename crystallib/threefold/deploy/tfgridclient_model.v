module deploy
import freeflowuniverse.crystallib.data.paramsparser


pub const version = '1.0.0'
const singleton = true
const default = true


const heroscript_default = "
!!tfdeployer.configure
    ssh_key: ''
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


pub fn (mut self TFGridClient) deployment_get(name string) !TFDeployment {
    mut d:=TFDeployment{}
    d.load(name)!
    return d
}


fn cfg_play(p paramsparser.Params) ! {
    network_str := p.get_default('network', 'main')!
    network := match network_str {
        'dev' { Network.dev }
        'test' { Network.test }
        else { Network.main }
    }

    mut mycfg := TFGridClient{
        ssh_key: p.get_default('ssh_key', '')!
        mnemonic: p.get_default('mnemonic', '')!
        network: network
    }
    set(mycfg)!
}