module main

import log
import freeflowuniverse.crystallib.data.markdownparser

fn main() {
	mut logger := log.Log{
		level: .debug
	}
	do(mut logger) or { logger.error('${err}') }
}

fn do(mut logger log.Log) ! {
	doc := markdownparser.new(
		path: '/home/mariocs/cs/crystallib/examples/data/markdownparser/test.md'
	)!
	println(doc)
}
