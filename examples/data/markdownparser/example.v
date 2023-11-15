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
	doc1 := markdownparser.new(
		path: '/home/mariocs/cs/crystallib/examples/data/markdownparser/test.md'
	)!
	content1 := doc1.markdown()

	doc2 := markdownparser.new(content: content1)!
	content2 := doc2.markdown()

	assert content1 == content2
}
