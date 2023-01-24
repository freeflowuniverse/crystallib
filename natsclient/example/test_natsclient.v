module main

import freeflowuniverse.crystallib.natsclient

import log
import flag
import os

fn process_messages(ch_receive_message chan natsclient.NATSMessage, mut natsclient natsclient.NATSClient, mut logger log.Logger) {
	for !ch_receive_message.closed {
		if select {
    		msg := <-ch_receive_message {
				// do something with the message here
				logger.info("MSG: $msg.message")
				natsclient.ack_message(msg.reply_to)
				logger.info("ACK message ${msg.sid} from subject ${msg.subject}")
    		}
		}{} else { }
	}
}

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

	ch_receive_message := chan natsclient.NATSMessage{}
	mut logger := log.Logger(&log.Log{ level: if debug_log { .debug } else { .info } })
	mut natsclient := natsclient.new_natsclient("ws://127.0.0.1:8880", ch_receive_message, &logger) or {
		logger.error(err.msg())
		return
	}
	natsclient.create_stream("mystream", ["ORDERS.*"]) or {
		logger.error("$err")
		return
	}
	
	natsclient.create_consumer("myconsumer", "mystream", "This is a consumer for the stream mystream") or {
		logger.error("$err")
		return
	}

	store := "mykeyvaluestore"
	natsclient.create_keyvalue_store(store) or {
		logger.error("$err")
		return
	}
	natsclient.add_keyvalue(store, "key1", "MODIFIED") or {
		logger.error("$err")
		return 
	}
	natsclient.add_keyvalue(store, "key5", "MODIFIED") or {
		logger.error("$err")
		return 
	}
	natsclient.get_value(store, "key1") or {
		logger.error("$err")
		return
	}

	_ := spawn process_messages(ch_receive_message, mut &natsclient, mut &logger)
	natsclient.listen() or {
		logger.error("$err")
	}
	ch_receive_message.close()
}