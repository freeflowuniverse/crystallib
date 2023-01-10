module main

import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.params

const domain="mydomain"

fn do() ! {


	mut text := "
		id:a1 name6:aaaaa
		name:'need to do something 1' 
		name2:   test
		name3: hi name10:'this is with space'  name11:aaa11
	"
	param := params.text_to_params(text) or { panic(err) }

	mut rmb:=rmbclient.new()!

	rmb.reset()!

	rmb.iam_register(src_rmbids:[u32(1),u32(2)])!


	//first one if the location of the one who will pick up the job, 0 is local
	mut ajob:=rmb.action_new(u32(0),"mydomain.myactor.myaction", param,"sourcedomain.sourceactor.soureaction")!

	println(ajob)

	d:=ajob.dumps()!
	println(d)

	mut ajob2:=rmbclient.job_load(d)!

	println(ajob2)

	rmb.action_schedule(mut ajob2)!

	mut job4:=rmb.job_get(ajob2.guid)!

	println(job4)

	// ajob2.run()!
	// data3:=ajob2.dumps()!



}

fn main() {
	do() or { panic(err) }
}
