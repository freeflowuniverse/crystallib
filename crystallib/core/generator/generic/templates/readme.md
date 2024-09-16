# ${args.name}

${args.title}

To get started

```vlang

@if args.cat == .installer

import freeflowuniverse.crystallib.installers.something. ${args.name}

mut installer:= ${args.name}.get()!

installer.start()!

@else

import freeflowuniverse.crystallib.clients. ${args.name}

mut client:= ${args.name}.get()!

client...

@end



```

## example heroscript

@if args.cat == .installer
```hero
!!${args.name}.install
    homedir: '/home/user/${args.name}'
    username: 'admin'
    password: 'secretpassword'
    title: 'Some Title'
    host: 'localhost'
    port: 8888

```
@else
```hero
!!${args.name}.configure
    secret: '...'
    host: 'localhost'
    port: 8888
```
@end


