module routeros

[heap]
pub struct RouterOS {
pub mut:
	vlans []Vlan
	addresses []Address
}

fn (ros RouterOS) vlan_exist(vlan Vlan) bool{
	for ros_vlan in ros.vlans{
		if ros_vlan.ifc == vlan.ifc{
			return true
		} 
	}
	return false
}

fn (ros RouterOS) address_exist(address Address) bool{
	for ros_addr in ros.addresses{
		if ros_addr.ifc == address.ifc{
			return true
		}
	}
	return false
}


pub struct Address {
	pub mut:
		ifc string
		ip string
		network string
}

pub struct Vlan {
	pub mut:
		name string
		ifc string
		id int
		mac string
}


pub fn (a Address) valid() bool {
	if a.ifc == "" || a.ip == "" || a.network == ""{
		return false
	} 
	return true
}

pub fn (a Address) render() string{
	return "||interface  : ${a.ifc}\n"+
	       "||address    : ${a.ip}\n"+
	       "||network    : ${a.network}"
}

pub fn (v Vlan) valid() bool {
	if v.name == "" || v.ifc == "" || v.id == 0 {
		return false
	} 
	return true
}
pub fn (v Vlan) render() string{
	return "||name       : ${v.name}\n" +
		   "||interface  : ${v.ifc}\n" +
		   "||mac-address: ${v.mac}\n" +
		   "||vlan-id    : ${v.id}\n" 
}

