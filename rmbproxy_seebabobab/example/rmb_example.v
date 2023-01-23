module main

import freeflowuniverse.crystallib.rmbproxy
import freeflowuniverse.crystallib.params


fn do() ! {


	mut text := "
		id:a1 name6:aaaaa
		name:'need to do something 1' 
		name2:   test
		name3: hi name10:'this is with space'  name11:aaa11
	"
	param := params.parser(text) or { panic(err) }

	mut rmbp:=rmbproxy.new()!
	mut rmb:=&rmbp.rmbc
	rmb.reset()!

	//schedule a job
	mut ajob:=rmb.action_new_schedule(u32(0),"mydomain.myactor.myaction", param,"sourcedomain.sourceactor.soureaction")!

	rmbproxy.process()!
}

fn main() {
	do() or { panic(err) }
}
