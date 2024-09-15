# generation framework



```bash
#will ask questions if .heroscript is not there yet
hero generate -p thepath_is_optional
# to generate without questions
hero generate -p thepath_is_optional -t client
#if installer, default is a client
hero generate -p thepath_is_optional -t installer

```

there will be a ```.heroscript``` in the director you want to generate for, the format is as follows:

```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```

```hero
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

//or for a client
!!hero_code.generate_client
    name:'mail' 
    classname:'MailClient'
    singleton:0            //default is 0
    default:1              //can we create a default when the factory is used
	reset:0                 // regenerate all, dangerous !!!    
    
```

needs to be put as .heroscript in the directories which we want to generate


## templates remarks

in templates:

- ^^ or @@ > gets replaced to @
- ?? > gets replaced to $

this is to make distinction between processing at compile time (pre-compile) or at runtime.

## call by code

to call in code

```v
import freeflowuniverse.crystallib.core.generator.installer

installer.scan("~/github/freeflowuniverse/crystallib/crystallib")!


```

to call from command line


```bash

#when path not specified then will generate for the path we are in
hero generate

hero generate -p ~/github/freeflowuniverse/crystallib/crystallib

#-r means reset, super dangerous, don't use, will remove changes, onlu use it for specific dirs
```