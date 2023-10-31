module main

import os
import time
import freeflowuniverse.crystallib.osal.zinit

fn main() {
	do() or { panic(err) }
}

fn do() ! {
	start_zinit()!
	client := zinit.new_rpc_client('crystallib/osal/zinit/zinit/zinit.sock')

	list_services(client)!
	get_service_status(client, 'service_2')!
	stop_service(client, 'service_2')!
	forget_service(client, 'service_2')!
	monitor_service(client, 'service_2')!
	stop_service(client, 'service_2')!
	start_service(client, 'service_2')!
	kill_service(client, 'service_1', 'sigterm')!
}

fn start_zinit() ! {
	spawn os.execute('zinit -s examples/osal/zinit/zinit.sock init -c examples/osal/zinit')
	time.sleep(time.second)
}

fn list_services(client zinit.Client) ! {
	mut ls := client.list()!
	println('services watched by zinit: ${ls}\n\n')
}

fn get_service_status(client zinit.Client, service_name string) ! {
	time.sleep(time.millisecond * 100)
	mut st := client.status(service_name)!
	println('${service_name} status: ${st}\n\n')
}

fn stop_service(client zinit.Client, service_name string) ! {
	println('Stopping ${service_name}...')
	client.stop(service_name)!
	get_service_status(client, service_name)!
}

fn forget_service(client zinit.Client, service_name string) ! {
	println('Forgetting ${service_name}...')
	client.forget(service_name)!
	list_services(client)!
}

fn monitor_service(client zinit.Client, service_name string) ! {
	println('Monitoring service ${service_name}...')
	client.monitor(service_name)!
	get_service_status(client, service_name)!
}

fn start_service(client zinit.Client, service_name string) ! {
	println('Starting service ${service_name}...')
	client.start(service_name)!
	get_service_status(client, service_name)!
}

fn kill_service(client zinit.Client, service_name string, sig string) ! {
	println('Killing service ${service_name}...')
	client.kill(service_name, sig)!
	get_service_status(client, service_name)!
}
