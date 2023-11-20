module hostsfile

import os
import freeflowuniverse.crystallib.osal

// TODO: will be broken now

[heap]
pub struct HostsFile {
pub mut:
	sections []Section
}

pub struct Section {
pub mut:
	name  string
	hosts []Host
}

pub struct Host {
pub mut:
	ip     string
	domain string
}

// pub fn new() HostsFile {
// 	mut obj := HostsFile{}

// 	mut content := os.read_file('/etc/hosts') or { panic(err) }
// 	mut section := ''

// 	for mut line in content.split('\n') {
// 		line = line.trim_space()
// 		if line.starts_with('#') {
// 			section = line.trim('#').trim_space()
// 			continue
// 		}

// 		mut splitted := line.fields()
// 		if splitted.len > 1 {
// 			if section !in obj.hosts {
// 				obj.hosts[section] = []map[string]string{}
// 			}
// 			obj.hosts[section] << {
// 				splitted[0]: splitted[1]
// 			}
// 		}
// 	}
// 	return obj
// }

// pub fn (mut hostsfile HostsFile) save(sudo bool) &HostsFile {
// 	mut str := ''
// 	for section, items in hostsfile.hosts {
// 		if section != '' {
// 			str = str + '# ${section}\n\n'
// 		}

// 		for item in items {
// 			for ip, domain in item {
// 				str = str + '${ip}\t${domain}\n'
// 			}
// 		}
// 		str = str + '\n\n'
// 	}
// 	if sudo {
// 		osal.execute_interactive('sudo -- sh -c -e "echo \'${str}\' > /etc/hosts"') or {
// 			panic(err)
// 		}
// 	} else {
// 		os.write_file('/etc/hosts', str) or { panic(err) }
// 	}
// 	return hostsfile
// }

// pub fn (mut hostsfile HostsFile) reset(sections []string) &HostsFile {
// 	for section in sections {
// 		if section in hostsfile.hosts {
// 			hostsfile.hosts[section] = []map[string]string{}
// 		}
// 	}
// 	return hostsfile
// }

// pub struct HostItemArg{
// pub mut:
// 	ip string
// 	domain string
// 	section string = "main"
// }

// pub fn (mut hostsfile HostsFile) add(args HostItemArg) &HostsFile {
// 	if args.section !in hostsfile.hosts {
// 		hostsfile.hosts[args.section] = []map[string]string{}
// 	}
// 	hostsfile.hosts[args.section] << {
// 		ip: domain
// 	}
// 	return hostsfile
// }

// pub fn (mut hostsfile HostsFile) delete(domain string) &HostsFile {
// 	mut indexes := map[string][]int{}

// 	for section, items in hostsfile.hosts {
// 		indexes[section] = []int{}
// 		for i, item in items {
// 			for _, dom in item {
// 				if dom == domain {
// 					indexes[section] << i
// 				}
// 			}
// 		}
// 	}

// 	for section, items in indexes {
// 		for i in items {
// 			hostsfile.hosts[section].delete(i)
// 		}
// 	}

// 	return hostsfile
// }

// pub fn (mut hostsfile HostsFile) delete_section(section string) &HostsFile {
// 	hostsfile.hosts.delete(section)
// 	return hostsfile
// }

// pub fn (mut hostsfile HostsFile) exists(domain string) bool {
// 	for _, items in hostsfile.hosts {
// 		for item in items {
// 			for _, dom in item {
// 				if dom == domain {
// 					return true
// 				}
// 			}
// 		}
// 	}
// 	return false
// }
