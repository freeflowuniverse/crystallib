
module deploy

import freeflowuniverse.crystallib.core.base
import os


__global (
    tfgridclient_global map[string]&TFGridClient
    tfgridclient_default string
)

/////////FACTORY

@[params]
pub struct ArgsGet{
pub mut:
    name string = "default"
    mnemonic string
    ssh_key string
}

fn args_get (args_ ArgsGet) ArgsGet {    
    mut args:=args_
    println(args)
    if args.name == ""{
        args.name = tfgridclient_default
    }

    if args.name == ""{
        args.name = "default"
    }

    return args
}
 
pub fn get(args_ ArgsGet) !&TFGridClient {
    mut args := args_get(args_)
    println("Arguments received: ${args}")
    
    // Check if the client exists in the global map
    if !(args.name in tfgridclient_global) {
        println("Client not found in global map for name: ${args.name}")
        
        if !config_exists(args_) {
            println("Configuration does not exist for: ${args.name}")
            
            if default {
                println("Saving default configuration for: ${args.name}")
                config_save(args_)!
            }
        }
        
        println("Loading configuration for: ${args.name}")
        config_load(args_)!
    }
    
    return tfgridclient_global[args.name] or { panic("TFGridClient not found for name: ${args.name}") }
}


//switch instance to be used for tfgridclient
pub fn switch(name string) {
    tfgridclient_default = name
}


fn config_exists(args_ ArgsGet) bool {
    mut args := args_get(args_)
    println("Checking if configuration exists for: ${args.name}")
    mut context := base.context() or { panic("Failed to get context") }
    return context.hero_config_exists("tfgridclient", args.name)
}

fn config_load(args_ ArgsGet) ! {
    mut args := args_get(args_)
    println("Loading configuration for: ${args.name}")
    myenv := os.environ()

	if args.mnemonic == "" && 'TFGRID_MNEMONIC' in myenv{
		args.mnemonic = myenv["TFGRID_MNEMONIC"]
	}

	if args.ssh_key == "" && 'SSH_KEY' in myenv{
		args.ssh_key = myenv["SSH_KEY"]
	}

    mut context := base.context()!
    mut heroscript := context.hero_config_get("tfgridclient", args.name)!
    
    // Assuming play creates a TFGridClient object, ensure to store it in the global map
    // Play the script to configure the client (if needed)
    play(heroscript: heroscript)!
    
    // Example: Assuming you create the TFGridClient object based on the configuration
    tfgridclient_global[args.name] = &TFGridClient{
        mnemonic: args.mnemonic
        ssh_key: args.ssh_key
    }

    println("TFGridClient has been created and stored for: ${args.name}")
}


fn config_save(args_ ArgsGet) ! {
    mut args := args_get(args_)
    println("Saving configuration for: ${args.name}")
    mut context := base.context()!
    context.hero_config_set("tfgridclient", args.name, heroscript_default)!
}


fn set(o TFGridClient)! {
    obj_init()!
    tfgridclient_global["default"] = &o
}


