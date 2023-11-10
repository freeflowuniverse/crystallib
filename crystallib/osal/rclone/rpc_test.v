module rclone

import os
import time

fn test_rclone() {
	// you need to have rclone in your path to run this test
	spawn os.execute('rclone -s crystallib/osal/rclone/rclone/rclone.sock init -c crystallib/osal/rclone/rclone')
	time.sleep(time.second)

	client := new_rpc_client('crystallib/osal/rclone/rclone/rclone.sock')

	mut ls := client.list()!
	mut want_ls := {
		'service_1': 'Running'
		'service_2': 'Running'
	}
	assert ls == want_ls

	mut st := client.status('service_2')!
	assert st.after == {
		'service_1': 'Running'
	}
	assert st.name == 'service_2'
	assert st.state == 'Running'
	assert st.target == 'Up'

	client.stop('service_2')!
	st = client.status('service_2')!
	assert st.target == 'Down'

	time.sleep(time.millisecond * 10)
	client.forget('service_2')!
	ls = client.list()!
	want_ls = {
		'service_1': 'Running'
	}
	assert ls == want_ls

	client.monitor('service_2')!
	time.sleep(time.millisecond * 10)
	st = client.status('service_2')!
	assert st.after == {
		'service_1': 'Running'
	}
	assert st.name == 'service_2'
	assert st.state == 'Running'
	assert st.target == 'Up'

	client.stop('service_2')!
	time.sleep(time.millisecond * 10)
	client.start('service_2')!
	st = client.status('service_2')!
	assert st.target == 'Up'

	client.kill('service_1', 'sigterm')!
	time.sleep(time.millisecond * 10)
	st = client.status('service_1')!
	assert st.state.contains('SIGTERM')
}
