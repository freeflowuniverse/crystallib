module publishermod

import despiegk.crystallib.publishconfig
import despiegk.crystallib.hostsfile

pub fn dns_on(sudo bool) {
	mut domains := []string{}
	mut myconfig := publishconfig.get() or { panic(err) }
	for site in myconfig.sites {
		for domain in site.domains {
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
	mut myconfig := publishconfig.get() or { panic(err) }
	for site in myconfig.sites {
		for domain in site.domains {
			domains << domain
		}
	}
	mut hostsfile := hostsfile.load()
	hostsfile.delete_section('pubtools')
	hostsfile.save(sudo)
}
