module builder

import freeflowuniverse.crystallib.ui.console

fn test_exec() {
	mut e := ExecutorLocal{}
	res := e.exec(cmd: 'ls  /') or { panic('error execution') }
	console.print_debug(res)
}

fn test_file_operations() {
	mut e := ExecutorLocal{}
	e.file_write('/tmp/abc.txt', 'abc') or { panic('can not write file') }
	mut text := e.file_read('/tmp/abc.txt') or { panic('can not read file') }
	assert text == 'abc'
	mut exists := e.file_exists('/tmp/abc.txt')
	assert exists == true
	e.delete('/tmp/abc.txt') or { panic(err) }
	exists = e.file_exists('/tmp/abc.txt')
	assert exists == false
}

fn test_environ_get() {
	mut e := ExecutorLocal{}
	mut env := e.environ_get() or { panic(err) }
	console.print_debug('${env}')
}

// TODO: fix
// fn test_node_new() {
// 	mut factory := new()!
// 	mut node := factory.node_new(name: 'localhost', reload: true) or {
// 		panic("Can't get new node: ${err}")
// 	}
// 	console.print_debug('${node}')
// }
