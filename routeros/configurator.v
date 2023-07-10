module routeros

pub struct Configurator {
pub mut:
	ros RouterOS
	configs []string // this will hold configs to be written to devices
}

pub fn (mut c Configurator) add_vlan(vlan Vlan) ! {
	if vlan.valid() && !c.ros.vlan_exist(vlan){

		c.configs << "/interface vlan add name=${vlan.name} vlan-id=${vlan.id} interface=${vlan.ifc}"
		c.ros.vlans << vlan
	}else{
		return error("vlan already exist")
	}
}

pub fn(mut c Configurator) assign_vlan_addess(addr Address) !{
	if addr.valid() && !c.ros.address_exist(addr){
		c.configs << "/ip address add interface=${addr.ifc} address=${addr.ip} "
		c.ros.addresses << addr
	}else{
		return error("address already exist")
	}
}

pub fn (mut c Configurator) add_dhcp_server(){}

pub fn(mut c Configurator) reset(keep_users bool, no_defaults bool){
	println("resetting routeros config on ...")
	mut cmd := "/system reset-configuration"
	if no_defaults{
		cmd += " no-defaults=yes"
	}

	if keep_users{
		cmd += " keep-uses=yes"
	}
	println(cmd)
}

pub fn (mut c Configurator) configure(){
	println("Executing commands on routeros ...")
	for config in c.configs {
		println(config)
		// c.connection.execute(config)
	}
	println("All commands executed successfully")
	c.configs = []
}

