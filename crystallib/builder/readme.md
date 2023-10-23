# BUILDER

## Initialization

```golang
import freeflowuniverse.crystallib.builder
mut b:=builder.new()
mut n:=b.node_get(ipaddr:"root@195.192.213.2:2222") //shorter way how to specify, user can also be done separate



```

## NODE DB

There is a type of database implemented on a node level, its basically a key value stor stored on the node.

Very useful to store values we don't wanna forget.

## EXECUTOR

We have executors implemented to work over SSH or for the LOCAL machine.

Each executor implements the following methods

- exec(cmd string) !string
- exec_silent(cmd string) !string
- file_write(path string, text string) !
- file_read(path string) !string
- file_exists(path string) bool
- delete(path string) !
- download(source string, dest string) !
- upload(source string, dest string) !
- environ_get() !map[string]string
- info() map[string]string
- shell(cmd string) !
- list(path string) ![]string
- dir_exists(path string) bool
- debug_off()
- debug_on()

