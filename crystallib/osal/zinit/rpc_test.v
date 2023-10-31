
module zinit

import os
import time

fn test_stop() {
	// you need to have zinit in your path to run this test
	spawn os.execute('zinit -s crystallib/osal/zinit/zinit/zinit.sock init -c crystallib/osal/zinit/zinit &')
	time.sleep(time.second)
	client := new_rpc_client('crystallib/osal/zinit/zinit/zinit.sock')
	st := client.status('hello')!
	println(st)

	client.stop('hello')!
	client.forget('hello')!
	client.monitor('hello')!
	client.start('hello')!
	client.kill('hello', 'sigterm')!

	ls := client.list()!
	println('zinit list ${ls}')
}
