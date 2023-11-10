# a sal to work with rclone

Rclone is this incredible swiss army knive to deal with S3 storage servers.


## Example

```golang
import freeflowuniverse.crystallib.osal.rclone

fn main() {
	do() or { panic(err) }
}

fn do() ! {
	mut z:=rclone.new()!

	// name      string            [required]
	// cmd       string            [required]
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

}

```

## protocol defined in


sal on top of https://github.com/threefoldtech/rclone/tree/master

https://github.com/threefoldtech/rclone/blob/master/docs/protocol.md