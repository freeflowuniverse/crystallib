module main

import freeflowuniverse.crystallib.natsclient

import log
import flag
import os

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('Example natsclient')
	fp.limit_free_args(0, 0)!
	fp.description('')
	fp.skip_executable()
	debug_log := fp.bool('debug', 0, false, 'log debug messages too')
	_ := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}

	mut logger := log.Logger(&log.Log{ level: if debug_log { .debug } else { .info } })
	mut natsclient := natsclient.new_natsclient("ws://127.0.0.1:8880", &logger) or {
		logger.error(err.msg())
		return
	}
	natsclient.create_stream("mystream", ["ORDERS.*"]) or {
		logger.error("$err")
	}
	natsclient.create_consumer("myconsumer", "mystream", "This is a consumer for the stream mystream") or {
		logger.error("$err")
	}
	natsclient.listen() or {
		logger.error("$err")
	}
}