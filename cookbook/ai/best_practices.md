

## normalize a string

We call this name fix, anytime we use a name as id, or as a key in a map we want to normalize the string

```v
import freeflowuniverse.crystallib.core.texttools
mut myname:="a__Name_to_fix"
myname = texttools.name_fix(myname)
```

## dealing with paths

alwayse use this library when dealing with path, info how to use it can be found in your knowledgebase from  core.pathlib.md

```v
import freeflowuniverse.crystallib.core.pathlib

#to get a path from a file or dir, the pathlib will figure out if its a dir or file and if it exists
mut p:=pathlib.get('/tmp/mysourcefiles')! 

#to get a dir and create it


#to get a list of paths and copy to other destination
mut pathlist:=p.list(regex:[r'.*.md$'])! //this gets all files ending on .md
pathlist.copy('/tmp/mydest')!

```

## executing commands 

```v

#simple commands, means < 1 line and can be executed using os.execute
# fn execute(cmd string) Result see os.md module
res := os.execute(cmd)
if res.exit_code > 0 {
    return error('cannot upload over ssh: ${cmd}')
}
#ALWAYS check the return code
```

#if the command is more complicated use the osal.exec method as can be found in osal.md file

res := osal.exec(cmd: args.cmd, stdout: args.stdout, debug: executor.debug)!
```


