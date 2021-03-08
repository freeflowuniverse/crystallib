module publishermod

import myconfig
import hostsfile

pub fn dns_on(sudo bool) {
	mut domains := []string{}
	mut myconfig := myconfig.get(true)or {panic(err)}
	for site in myconfig.sites {
		for domain, _ in site.domains {
			domains << domain
		}
	}
	mut hostsfile := hostsfile.load()
	hostsfile.delete_section('pubtools')
	for domain in domains {
		hostsfile.add('127.0.0.1', domain, 'pubtools')
	}
	hostsfile.save(sudo)
}

pub fn dns_off(sudo bool) {
	mut domains := []string{}
	mut myconfig := myconfig.get(true) or {panic(err)}
	for site in myconfig.sites {
		for domain, _ in site.domains {
			domains << domain
		}
	}
	mut hostsfile := hostsfile.load()
	hostsfile.delete_section('pubtools')
	hostsfile.save(sudo)
}
