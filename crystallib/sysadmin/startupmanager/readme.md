# startup manager

```go
import freeflowuniverse.crystallib.sysadmin.startupmanager
mut sm:=startupmanager.get()!


sm.start(
    name: 'myscreen'
    cmd: 'htop'
    description: '...'
)!

```


## some basic commands for screen

```bash
#list the screens
screen -ls
#attach to the screens
screen -r myscreen
```

to exit a screen to  

```
ctrl a d
```

