module routeros

//at init, load all relevant info from routeros
fn (mut ro RouterOS) load()!{
	ro.load_vlans()
	ro.load_addresses()
}

pub fn (mut ro RouterOS) load_vlans(){
	// TODO: get actual data from routeros using ssh
	// /interface/vlan print proplist=name,interface,mac-address,vlan-id without-paging detail
	vlans :=(
		'
	Flags: X - disabled, R - running 
 0   name="vlan1" interface=ether1 mac-address=DC:2C:6E:6D:B4:B1 vlan-id=1 

 1   name="vlan2" interface=ether2 mac-address=DC:2C:6E:6D:B4:B2 vlan-id=2 

'
	)

	ro.vlans = routeros.parse_vlans(vlans)

}

pub fn (mut ro RouterOS) load_addresses(){
	// TODO: get actual data from routeros using ssh
	// /ip/address print proplist=address,interface,network without-paging detail
	addresses := (
	'
	Flags: X - disabled, I - invalid, D - dynamic 
 0   ;;; defconf
     address=192.168.88.10/24 interface=bridge network=192.168.88.0 

 1   address=10.10.20.1/32 interface=vlan2 network=10.10.20.1 


	'
	)
	ro.addresses = routeros.parse_addresses(addresses)
	
}

pub fn (mut ro RouterOS) print_config(){
	println("==================== Vlans Configurations ====================")
	for vlan in ro.vlans{
		println(vlan.render())
		println("-------------------------------------")
	}
	println("================== Addresses Configuration ===================")
	for address in ro.addresses{
		println(address.render())
		println("-------------------------------------")
		
	}
	

}

