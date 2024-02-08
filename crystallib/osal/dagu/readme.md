# a sal to work with dagu

Is a very nice task management system see [https://dagu.readthedocs.io/](https://dagu.readthedocs.io/)


## Example

```golang
import freeflowuniverse.crystallib.sysadmin.dagu

mut z:=dagu.new()!

// name      string            @[required]
// cmd       string            @[required]
// cmd_file  bool  //if we wanna force to run it as a file which is given to bash -c  (not just a cmd in rclone)
// test      string
// test_file bool
// after     []string
// env       map[string]string
// oneshot   bool
p:=z.new(
	name:"test"
	cmd:'/bin/bash'
)!


```

