module caddy

import os
import freeflowuniverse.crystallib.core.pathlib
import net.urllib

// Function to load Caddyfile into the data structure
pub fn load_caddyfile(path string) !CaddyFile {
	mut caddyfile := CaddyFile{
		path: path
	}

	mut file := pathlib.get_file(path: path, create: true)!
	content := file.read()!
	lines := content.split('\n')

	mut site_block := SiteBlock{}
	mut current_matchers := []Matcher{}
	mut in_site_block := false
	for line in lines {
		trimmed_line := line.trim_space()
		if trimmed_line.starts_with('#') || trimmed_line.len == 0 {
			continue // Ignore comments and empty lines
		}

		if trimmed_line.contains('{') {
			in_site_block = true
			address_line := trimmed_line.all_before('{').trim_space()
			if address_line.len > 0 {
				// This is an address line
				mut parts := address_line.split(',')
				for mut part in parts {
					part = part.trim_space()
					if !part.starts_with('http') {
						part = 'http://${part}'
					}
					url := urllib.parse(part)!
					mut host_parts := url.host.split(':')
					domain := host_parts[0]
					port := if host_parts.len > 1 { host_parts[1].int() } else { 0 }
					site_block.addresses << Address{
						domain: domain
						port: port
					}
				}
			}
			continue
		}

		if trimmed_line.contains('}') {
			caddyfile.site_blocks << site_block
			site_block = SiteBlock{}
			in_site_block = false
			current_matchers.clear()
			continue
		}

		if in_site_block {
			// This is a directive line within a site block
			mut parts := trimmed_line.split(' ')
			directive_name := parts[0]
			directive_args := parts[1..]
			directive := Directive{
				name: directive_name
				args: directive_args
				matchers: current_matchers.clone()
			}
			site_block.directives << directive
		}
	}

	if in_site_block {
		// Add the last site block if the file doesn't end with a closing brace
		caddyfile.site_blocks << site_block
	}

	return caddyfile
}
