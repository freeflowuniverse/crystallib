module builder

import rand

// Assuming this function runs first (which is the case)
// This generates ssh keys on local machine to use for 
// connecting to local host over ssh and test executor
fn test_init() {
	mut e := ExecutorLocal{}
	e.exec("yes '' | ssh-keygen -t rsa  -f ~/.ssh/id_rsa_test -N ''") or {panic(err)}
	e.exec('chmod 0600 ~/.ssh/id_rsa_test && chmod 0644 ~/.ssh/id_rsa_test.pub')or {panic(err)}
	e.exec('cat ~/.ssh/id_rsa_test.pub >> ~/.ssh/authorized_keys')or {panic(err)}
	e.exec('chmod og-wx ~/.ssh/authorized_keys')or {panic(err)}
	println("x")
}

fn test_exec() {
	mut e := ExecutorSSH{
		sshkey: '~/.ssh/id_rsa_test'
	}
	e.ipaddr = IPAddress{
		addr: '127.0.0.1'
		port: 22
	}
	res := e.exec('ls  /') or {panic(err)}
	println(res)
}

fn test_file_operations() {
	mut e := ExecutorSSH{
		sshkey: '~/.ssh/id_rsa_test'
	}
	e.ipaddr = IPAddress{
		addr: '127.0.0.1'
		port: 22
		cat: IpAddressType.ipv4
	}
	mut filepath := '/tmp/$rand.uuid_v4()'
	e.file_write(filepath, 'ssh') or { panic('error writing file') }
	mut text := e.file_read(filepath) or { panic('can not read file') }
	assert text == 'ssh'
	mut exists := e.file_exists(filepath)
	assert exists == true
	e.remove(filepath) or {panic(err)}
	exists = e.file_exists(filepath)
	assert exists == false
}

fn test_environ_get() {
	mut e := ExecutorSSH{
		sshkey: '~/.ssh/id_rsa_test'
	}
	e.ipaddr = IPAddress{
		addr: '127.0.0.1'
		port: 22
		cat: IpAddressType.ipv4
	}
	mut env := e.environ_get() or { panic(err) }
	println(env)
}

// fn test_remote_machine(){
// 	mut e := ExecutorSSH{
// 		sshkey: "~/.ssh/id_rsa_test",
// 		user: "root",
// 		ipaddr: IPAddress{
// 			addr: "104.236.53.191",
// 			port: Port{
// 				number: 22,
// 				cat: PortType.tcp
// 			},
// 			cat: IpAddressType.ipv4
// 		}
// 	}
// 	res := e.exec("ls  /root") or {panic(err)}
// 	println(res)
// }
