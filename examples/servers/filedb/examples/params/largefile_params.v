module main

import os
import io
import benchmark
import time
import freeflowuniverse.crystallib.params

const testpath = '/tmp/test'

fn find_item(myfilter params.ParamsFilter) !string {
	mut ff := os.open(testpath)!

	mut buffered_reader := io.new_buffered_reader(reader: ff)
	mut stdout := os.stdout()

	defer {
		ff.close()
	}

	for {
		mut r := buffered_reader.read_line() or { break }
		p := params.parse(r)!
		if p.filter_match(myfilter)! {
			return r
		}
	}

	return error('could not find: ${myfilter}')
}

fn find_benchmark(nr int) {
	counter := 100

	mut bmark := benchmark.new_benchmark()

	for i in 0 .. counter {
		t := nr - 100 - i
		r := find_item(include: ['description:*description_${t}']) or { panic(err) }
		// println(r)
		bmark.ok()
	}

	bmark.stop()

	nritems := 1000 * counter / bmark.total_duration()
	println('nr of items per sec find: ${nritems}')

	// time.sleep(1000 * time.millisecond)

	// copy_to_stdout()
}

fn main() {
	counter := 50000

	if os.exists(testpath) {
		os.rm(testpath)!
	}

	mut ff := os.open_append(testpath)!

	mut bmark := benchmark.new_benchmark()

	for i in 0 .. counter {
		ff.write_string("color:r${i} urgent depth:'${i},${i + 1}' description:'a longer description_${i}'\n")!
		bmark.ok()
	}
	ff.close()
	bmark.stop()

	nritems := 1000 * counter / bmark.total_duration()
	println('nr of items per sec for write: ${nritems}')
	// copy_to_stdout()
	find_item('*some line with a nr: 499') or { panic(err) }

	find_benchmark(counter)
}
