## ping

```go
assert ping(address:"338.8.8.8")==.unknownhost
assert ping(address:"8.8.8.8")==.ok
assert ping(address:"18.8.8.8")==.timeout
```

will do a panic if its not one of them, an unknown error

## platform

```go
if platform()==.osx{
    //do something
}

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub enum CPUType {
	unknown
	intel
	arm
	intel32
	arm32
}

```

## process


### execute jobs

```v
mut job2:=osal.exec(cmd:"ls /")?
println(job2)

//wont die, the result can be found in /tmp/execscripts
mut job:=osal.exec(cmd:"ls dsds",ignore_error:true)?
//this one has an error
println(job) 
```

All scripts are executed from a file from /tmp/execscripts

If the script executes well then its removed, so no leftovers, if it fails the script stays in the dir

### check process logs

```
mut pm:=process.processmap_get()?
```

info returns like:

```json
}, freeflowuniverse.crystallib.process.ProcessInfo{
        cpu_perc: 0
        mem_perc: 0
        cmd: 'mc'
        pid: 84455
        ppid: 84467
        rss: 3168
    }, freeflowuniverse.crystallib.process.ProcessInfo{
        cpu_perc: 0
        mem_perc: 0
        cmd: 'zsh -Z -g'
        pid: 84467
        ppid: 84469
        rss: 1360
    }]
```

## work with profiles

```v
osal.profile_path_add_remove(paths2delete:"go/bin",paths2add:"~/hero/bin,~/usr/local/bin")!
```

