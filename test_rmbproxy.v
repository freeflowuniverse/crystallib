module main

import freeflowuniverse.crystallib.rmbproxy
import log
import flag
import os

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('Example rmbproxy')
	fp.limit_free_args(0, 0) or { panic(err) }
	fp.description('')
	fp.skip_executable()
	port := fp.int('port', 0, 8880, 'port to run the websocket server on')
	_ := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	mut logger := log.Logger(&log.Log{
		level: .debug
	})

	rmbproxy.run(port, &logger) or { panic(err) }
}
