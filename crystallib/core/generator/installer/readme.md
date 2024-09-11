in templates:

- ^^ > gets replaced to @
- ?? > gets replaced to $

this is to make distinction between processing at compile time (pre-compile) or at runtime.


```bash

name                  string   @[required]
classname             string   @[required]
default               bool means user can just get the object and a default will be created
title                 string
supported_platforms   []string
configure_interactive bool
singleton             bool means there can only be one
templates             bool
reset                 bool regenerate all, dangerous !!!
startupmanager        bool = true
build                 bool


```

to be used for a heroscript example:

```yaml
!!hero_code.generate_installer
    name:'daguserver' 
    classname:'DaguServer'
    singleton:1            //there can only be 1 object in the globals, is called 'default'
    templates:1            //are there templates for the installer
    default:1              //can we create a default when the factory is used
	title:''
	supported_platforms:'' //osx, ... (empty means all)
	reset:0                 // regenerate all, dangerous !!!
	startupmanager:1      //managed by a startup manager, default true
    build:1                 //will we also build the component
```

needs to be put as .heroscript in the directories which we want to generate

to call in code

```v
import freeflowuniverse.crystallib.core.generator.installer

installer.scan("~/github/freeflowuniverse/crystallib/crystallib")!


```

to call from command line


```bash

```