module main

import freeflowuniverse.crystallib.terraform
import threefoldtech.vgrid.gridproxy

const sshkey = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC/9RNGKRjHvViunSOXhBF7EumrWvmqAAVJSrfGdLaVasgaYK6tkTRDzpZNplh3Tk1aowneXnZffygzIIZ82FWQYBo04IBWwFDOsCawjVbuAfcd9ZslYEYB3QnxV6ogQ4rvXnJ7IHgm3E3SZvt2l45WIyFn6ZKuFifK1aXhZkxHIPf31q68R2idJ764EsfqXfaf3q8H3u4G0NjfWmdPm9nwf/RJDZO+KYFLQ9wXeqRn6u/mRx+u7UD+Uo0xgjRQk1m8V+KuLAmqAosFdlAq0pBO8lEBpSebYdvRWxpM0QSdNrYQcMLVRX7IehizyTt+5sYYbp6f11WWcxLx0QDsUZ/J'

fn do() ? {
	// get link to terraform factory (allows you to deploy anything on TFGrid)
	// if terraform client not install will do it automatically
	mut tf := terraform.get()?

	// last true means caching is on
	mut gp_client := gridproxy.get(.test, true)
	// farms := gp_client.get_farms()?
	// get gateway list
	// gateways := gp_client.get_gateways()?
	// get contract list
	// contracts := gp_client.get_contracts()?
	// get grid stats
	// stats := gp_client.get_stats()?
	// get node list
	nodes_available := gp_client.get_nodes(dedicated: true, free_ips: u64(1))?
	// println(nodes)
	// amazing documentation on https://github.com/threefoldtech/vgrid/blob/development/gridproxy/README.md

	// make sure the following env is set  TFGRID_MNEMONIC, is your private key
	// can also set: TFGRID_SSHKEY as env variable, or specify as in this example
	// select wich network you want to use, .test or .main or.dev
	mut d := tf.deployment_get(
		name: 'test'
		sshkey: sshkey
		tfgridnet: .test
	)?

	// mut vm1 := d.vm_ubuntu_add(
	// 	name: 'kds1'
	// 	nodes: nodes_available
	// 	memory_gb: 8
	// 	public_ip: true
	// )?

	// mut vm2 := d.vm_ubuntu_add(
	// 	name: 'kds2'
	// 	nodes: nodes_available
	// 	memory_gb: 8
	// 	public_ip: false
	// )?

	// // add disk of 10GB mounted on root for vm2
	// vm2.disk_add(10, '/root')

	// // lets first destroy before we deploy, so there are no leftovers
	// // if you don't destroy will try to match what was already deployed
	// d.destroy()?
	// // lets deploy our solution
	// d.deploy()?

	// // print how vm2 looks like
	// println(vm2)

	// mut node := vm2.sshnode_get()?
}

// fn do2() ? {
// 	mut explorer := explorer.get(.test)

// 	// ns := explorer.nodes_find(mem_min_gb:50,hdd_min_gb:1000,public_ip:true)?
// 	// ns := explorer.nodes_find(mem_min_gb:50,public_ip:true)?
// 	// ns := explorer.nodes_find(public_ip:true,country:"belgium")?
// 	// ns := explorer.nodes_find(public_ip:true,region:.europe_west)?

// 	// ns := explorer.node_find(public_ip:true,region:.europe_west)?

// 	// next will give a random node because is region world
// 	ns := explorer.node_find(region: .world)?

// 	// today we only have region:.europe_west and world defined (and even very rough)
// 	// ns := explorer.nodes_find(region:.europe_west)?
// 	println(ns)
// }

fn main() {
	// main loop, just call our main method & panic if issues
	do() or { panic(err) }
}
