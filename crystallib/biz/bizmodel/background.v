module bizmodel

// import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.biz.spreadsheet
import json
import sync

pub struct BizModelBackground {
pub mut:
	ourthread &spawner.OurThread
}

// run the business tool in a thread .
// .
// pass the path in args
// initialize the spawner first e.g. mut s:=spawner.new()

// TODO: fix and uncomment
// pub fn background(mut s spawner.Spawner, args BizModelArgs) !BizModelBackground {
// 	///spawn the process and wait for 3scripts to be fed

// 	// QUESTION: what is bizmodel_do supposed to be
// 	mut t := s.thread_add('bizmodel', bizmodel_do)!
// 	// time.sleep(time.Duration(time.second))

// 	mut res := t.rpc(method: 'LOAD', val: args.path)! // will make sure biz model gets loaded
// 	if res != 'OK' {
// 		return error("could not load the biz model in the thread: '${res}'")
// 	}
// 	println('BIZMODEL LOADED')
// 	return BizModelBackground{
// 		ourthread: t
// 	}
// }
