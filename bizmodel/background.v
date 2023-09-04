module bizmodel

import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.spreadsheet
import json
import sync

pub struct BizModelBackground {
pub mut:
	ourthread &spawner.OurThread
}

fn bizmodel_do(mut ch_in sync.Channel, mut ch_out sync.Channel) {
	println('biz model thread start')
	mut rpcobj := spawner.RPCArg{}
	mut m := new(path: rpcobj.val) or { panic(err) }
	for i in 0 .. 10000000000 {
		// println(" - T: will receive")
		ch_in.pop(&rpcobj)
		if rpcobj.method == 'STOP' {
			println('STOP')
			return
		}
		// LOAD
		if rpcobj.method.to_upper().trim_space() == 'LOAD' {
			println('BIZMODEL LOAD: path:${rpcobj.val}')
			if rpcobj.val.len == 0 {
				rpcobj.error = 'val cannot be empty for load, is path of the bizmodel'
			}
			m = new(path: rpcobj.val) or {
				rpcobj.error = 'Could not load bizmodel.\n${err}'
				new(path: rpcobj.val) or { panic(err) } // return empty one
			}
			rpcobj.result = 'OK'
		}

		if m.params.path == '' {
			// means is not loaded yet
			rpcobj.error = 'Bizmodel not loaded, need to do a load action first.'
		}
		// WIKI
		if rpcobj.method.to_upper().trim_space() == 'WIKI' {
			// println("WIKI:${rpcobj.val}")
			data := json.decode(spreadsheet.WikiArgs, rpcobj.val) or { panic(err) } // is bug so ok to panic
			rpcobj.result = m.sheet.wiki(data) or {
				rpcobj.error = '${err}'
				''
			}
		}

		// BARCHART1
		if rpcobj.method.to_upper().trim_space() == 'BARCHART1' {
			// println("BARCHART1:${rpcobj.val}")
			data := json.decode(spreadsheet.RowGetArgs, rpcobj.val) or { panic(err) } // is bug so ok to panic
			rpcobj.result = m.sheet.wiki_bar_chart(data) or {
				rpcobj.error = '${err}'
				''
			}
		}

		// PIECHART1
		if rpcobj.method.to_upper().trim_space() == 'PIECHART1' {
			// println("BARCHART1:${rpcobj.val}")
			data := json.decode(spreadsheet.RowGetArgs, rpcobj.val) or { panic(err) } // is bug so ok to panic
			rpcobj.result = m.sheet.wiki_pie_chart(data) or {
				rpcobj.error = '${err}'
				''
			}
		}

		// println("DONE:${rpcobj.val}")
		if !rpcobj.async {
			// println(" - T: will send")
			ch_out.push(&rpcobj)
		}
	}
}

// run the business tool in a thread .
// .
// pass the path in args
// initialize the spawner first e.g. mut s:=spawner.new()
pub fn background(mut s spawner.Spawner, args BizModelArgs) !BizModelBackground {
	///spawn the process and wait for 3scripts to be fed

	mut t := s.thread_add('bizmodel', bizmodel_do)!
	// time.sleep(time.Duration(time.second))

	mut res := t.rpc(method: 'LOAD', val: args.path)! // will make sure biz model gets loaded
	if res != 'OK' {
		return error("could not load the biz model in the thread: '${res}'")
	}
	println('BIZMODEL LOADED')
	return BizModelBackground{
		ourthread: t
	}
}

// get wiki representation of the data from the sheet
//
// name          string .
// namefilter    []string // only include the exact names as secified for the rows .
// includefilter []string // matches for the tags .
// excludefilter []string // matches for the tags .
// period_months int = 12 // 3 for quarter, 12 for year, 1 for all months .
// description   string .
// title         string .
// title_disable bool .
// rowname       bool = true .
pub fn (mut m BizModelBackground) wiki(args spreadsheet.WikiArgs) !string {
	return m.ourthread.rpc(method: 'WIKI', val: json.encode(args))!
}
