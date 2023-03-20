module routeros

pub fn parse_addresses(data string) []Address{
	mut addresses := []Address{}
	for mut line in data.split("\n"){
		line = line.trim_space() 
		mut address := Address{}
		if line.contains('='){
			props := line.split(' ')
			for prop in props {
				if prop.contains('='){
					sub_elements := prop.trim_space().split('=')
					if sub_elements.len < 1{
						continue
					}
					if sub_elements[0] == 'address'{
						address.ip = sub_elements[1]
					}else if sub_elements[0] == "network"{
							address.network = sub_elements[1]
					}else if sub_elements[0] == "interface"{
							address.ifc = sub_elements[1]
					}
				}	
			}		
			addresses << address
		}
	}
		return addresses
}

pub fn parse_vlans(data string) []Vlan{
	mut vlans := []Vlan{}
	for mut line in data.split("\n"){
		line = line.trim_space() 
		mut vlan := Vlan{}
		if line.contains('='){
			props := line.split(' ')
			for prop in props {
				if prop.contains('='){
					sub_elements := prop.trim_space().split('=')
					if sub_elements.len < 1{
						continue
					}
					if sub_elements[0] == 'name'{
						vlan.name = sub_elements[1]
					}else if sub_elements[0] == "interface"{
							vlan.ifc = sub_elements[1]
					}else if sub_elements[0] == "mac-address"{
							vlan.mac = sub_elements[1]
					}else if sub_elements[0] == "vlan-id"{
							vlan.id = sub_elements[1].u16()
					}

				}	
			}		
			vlans << vlan
		}
	}
		return vlans
}