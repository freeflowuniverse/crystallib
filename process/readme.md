# Process Tools

## execute jobs

```v
mut job2:=process.execute_job(cmd:"ls /")?
println(job2)

//wont die, the result can be found in /tmp/execscripts
mut job:=process.execute_job(cmd:"ls dsds",die:false)?
//this one has an error
println(job) 
```

All scripts are executed from a file from /tmp/execscripts

If the script executes well then its removed, so no leftovers, if it fails the script stays in the dir

## check process logs

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