module luadns

import os
import freeflowuniverse.crystallib.core.pathlib

fn parse_dns_configs(directory_path string) ![]DNSConfig {
	mut configs := []DNSConfig{}

	mut luadns_dir := pathlib.get_dir(path: directory_path)!

	mut list := luadns_dir.list()!

	for mut file in list.paths {
		if file.extension() == 'lua' {
			config := parse_luadns_file(file.path)!
			configs << config
		}
	}

	return configs
}

fn parse_luadns_file(file_path string) !DNSConfig {
	mut config := DNSConfig{}

	mut file := pathlib.get_file(path: file_path)!
	content := file.read()!

	for line in content.split('\n') {
		trimmed_line := line.trim_space()
		if trimmed_line.len == 0 || trimmed_line.starts_with('//') {
			continue
		}

		if trimmed_line.starts_with('a(') {
			parts := trimmed_line.all_after('a(').all_before(')').split(',')
			name := parts[0].trim('" ')
			ip := parts[1].trim('" ')
			config.a_records << ARecord{name, ip}
		} else if trimmed_line.starts_with('cname(') {
			parts := trimmed_line.all_after('cname(').all_before(')').split(',')
			name := parts[0].trim('" ')
			alias := parts[1].trim('" ')
			config.cname_records << CNAMERecord{name, alias}
		} else if trimmed_line.starts_with('caa(') {
			parts := trimmed_line.all_after('caa(').all_before(')').split(',')
			name := parts[0].trim('" ')
			value := parts[1].trim('" ')
			tag := parts[2].trim('" ')
			config.caa_records << CAARecord{name, value, tag}
		}
	}

	config.domain = os.base(file_path).all_before('.lua')
	return config
}
