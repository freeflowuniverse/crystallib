#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.clients.namecom
import freeflowuniverse.crystallib.core.pathlib


fn write_domain_file(domain_name string, records []namecom.Record)!{
	mut p := pathlib.get_file(path: '/root/code/github/freeflowuniverse/crystallib/crystallib/clients/namecom/output/${domain_name}', create: true)!
	for record in records{
		p.write(record.write()!)!
	}
}

username := 'despiegk'
token := 'c17cdf4cb49989c120535cb28be900b133eae244'

domains := namecom.list_domains(username, token)!



println('Domains:')
for id, domain in domains.domains {
	println('- ${domain.domain_name}')

	records := namecom.list_records(domain.domain_name, username, token) or {
		println('Error: ${err}')
		continue
	}

	// println('Records for ${domain.domain_name}:')
	// for record in records.records {
	// 	println('ID: ${record.id}, Host: ${record.host}, Type: ${record.type_}, Answer: ${record.answer}')
	// }

	write_domain_file(domain.domain_name, records.records)!

	// println('Next page: ${records.next_page}')
	// println('Last page: ${records.last_page}')

	// println('  Locked: ${domain.locked}')
	// println('  Autorenew Enabled: ${domain.autorenew_enabled}')
	// println('  Expire Date: ${domain.expire_date}')
	// println('  Create Date: ${domain.create_date}')
	// println('')
}



println('number of domains: ${domains.domains.len}')

println('Next dom Page: ${domains.next_page}')
println('Last dom Page: ${domains.last_page}')

