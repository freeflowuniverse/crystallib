
module blockchain

import freeflowuniverse.crystallib.core.playbook


__global (
    blockchain_global map[string]&DigitalAssets
    blockchain_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
}

fn args_get (args_ ArgsGet) ArgsGet {
    mut args:=args_
    if args.name == ""{
        args.name = blockchain_default
    }
    if args.name == ""{
        args.name = "default"
    }
    return args
}

pub fn get(args_ ArgsGet) !&DigitalAssets  {
    mut args := args_get(args_)
    if !(args.name in blockchain_global) {    
        mut da:=DigitalAssets{name:args.name}
        set(da)!                    
    }
    return blockchain_global[args.name] or { 
            println(blockchain_global)
            panic("bug in get from factory: ") 
        }
}

fn set(o DigitalAssets)! {
    blockchain_global[o.name] = &o
}


@[params]
pub struct PlayArgs {
pub mut:
    name string = 'default'
    heroscript string  //if filled in then plbook will be made out of it
    path string
    plbook     ?playbook.PlayBook 
    //reset      bool
}

pub fn play(args_ PlayArgs) ! {
    
    mut args:=args_

    mut plbook := args.plbook or {
        playbook.new(text: args.heroscript,path:args.path)!
    }
    
    mut myactions := plbook.find(filter: 'blockchain.account')!
    if myactions.len > 0 {
        for install_action in myactions {
            mut p := install_action.params
            play_asset(p)!
        }
    }

}




//switch instance to be used for blockchain
pub fn switch(name string) {
    blockchain_default = name
}
