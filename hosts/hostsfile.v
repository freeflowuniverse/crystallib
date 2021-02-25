module hostsfile

import os


pub struct HostsFile{
	pub mut:
		hosts map[string][]map[string]string
}

pub fn load() HostsFile{
	mut obj := HostsFile{}

	mut content := os.read_file("/etc/hosts") or {panic(err)}
	mut section := ""

	for mut line in content.split("\n"){
		line = line.trim_space()
		if line.starts_with("#"){
			section = line.trim("#").trim_space()				
				continue
		}	

		mut splitted := line.split_by_whitespace()
		if splitted.len > 1 {
				if !(section in obj.hosts){
					obj.hosts[section] = []map[string]string{}
				}
				obj.hosts[section] << map{splitted[0] : splitted[1]}
		}
	}
	return   obj
}

pub  fn (mut hostsfile HostsFile) save() &HostsFile{
	mut str := ""
	for section, items in hostsfile.hosts{
		if section != ""{
			str = str + "# $section\n\n"
		}
		
		for item in items{
			for ip, domain in item{
				str = str + "$ip\t$domain\n"
			}
		}
		str = str + "\n\n"
	}
	os.write_file("/etc/hosts", str) or {panic(err)}
	return hostsfile
}


pub  fn (mut hostsfile HostsFile) reset(sections []string) &HostsFile{
	for section in sections{
		if section in hostsfile.hosts{
			hostsfile.hosts[section] = []map[string]string{}
		}
	}
	return hostsfile
}

pub  fn (mut hostsfile HostsFile) add(ip string, domain string, section string) &HostsFile{
	if !(section in hostsfile.hosts){
			hostsfile.hosts[section] = []map[string]string{}
	}
	hostsfile.hosts[section] << map{ip : domain}
	return hostsfile
}


pub fn (mut hostsfile HostsFile) delete(domain string) &HostsFile{
	mut indexes := map[string][]int{}

	for section, items in hostsfile.hosts{
		indexes[section] = []int{}
		for i, item in items{
			for _, dom in item{
				if dom == domain{
					indexes[section] << i
				}
			}
		}
	}

	for section, items in indexes{
		for i in items{
			hostsfile.hosts[section].delete(i)
		}
	}

	return hostsfile
}


pub fn (mut hostsfile HostsFile) exists(domain string) bool{
	for _, items in hostsfile.hosts{
		for item in items{
			for _, dom in item{
				if dom == domain{
					return true
				}
			}
		}
	}
	return false
}



