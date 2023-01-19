module main

import freeflowuniverse.crystallib.rmbprocessor

import log
import flag
import os

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('Example rmbprocessor')
	fp.limit_free_args(0, 0)!
	fp.description('')
	fp.skip_executable()
	_ := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	mut logger := log.Logger(&log.Log{ level: .debug })
	mut natsclient := rmbprocessor.new_natsclient("ws://127.0.0.1:8880", &logger) or {
		logger.error(err.msg())
		return
	}
	natsclient.listen() or {
		logger.error(err.msg())
	}
}