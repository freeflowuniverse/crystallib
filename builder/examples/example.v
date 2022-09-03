module main

import builder
import os


fn do() ? {

	n := node.node_get({}) or { panic(err) }
	res := n.executor.execute('ls /')

}

fn main() {
	do() or { panic(err) }
}
