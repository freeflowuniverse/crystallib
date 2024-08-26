
# caddy installer

see /root/code/github/freeflowuniverse/crystallib/manual/collections/heroscript/installers/caddy.md

```go

import freeflowuniverse.crystallib.installers.web.caddy as caddyinstaller
import freeflowuniverse.crystallib.core.playbook

heroscript := "
!!caddy.install
    xcaddy:true
    plugins:'github.com/mholt/caddy-webdav,github.com/mohammed90/caddy-git-fs,github.com/abiosoft/caddy-exec,github.com/greenpau/caddy-security'
    restart:true
    reset:true
    homedir:'/root/www'
    xcaddy:1

"

mut plbook := playbook.new(text: heroscript)!
caddyinstaller.play(mut plbook)!
    

```


# example

- see /root/code/github/freeflowuniverse/crystallib/examples/servers/caddy/example_caddy.vsh

