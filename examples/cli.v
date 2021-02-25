module main

import os
import cli

sub_exec := fn (cmd cli.Command) ? {
    println('hello subcommand')
    println(cmd.args)
    // println(cmd.flags[1])
    o:=cmd.flags[1].get_string()?
    println(o)
    return
}

mut sub_cmd := cli.Command{
    name: 'sub'
    usage: 'arg1 arg2'
    execute: sub_exec
    required_args: 2
}

sub_cmd.add_flag(cli.Flag{
    name: 'test'
    abbrev: 't'
    description: 'this is a test argument'
    // required: true
    flag: cli.FlagType.string
})

// plus_exec := fn (cmd cli.Command) ? {
//     println('hello app')
//     return
// }

mut main_cmd := cli.Command{
    name: 'example-app'
    description: 'example-app'
    commands: [sub_cmd]
    usage: "

    need to specify one of following commands:

    - sub
    - plus

    "    
}

main_cmd.setup()
main_cmd.parse(os.args)

//TOTEST:
//v run cli.v sub a b
//v run cli.v sub -h
//v run cli.v sub -t z a b
//v run cli.v sub --test z a b
//v run cli.v sub a b
//v run cli.v -h
