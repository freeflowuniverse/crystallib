module caddy

import os
import freeflowuniverse.crystallib.core.pathlib
import net.urllib

fn load_caddyfile(path string) !CaddyFile {
	mut caddyfile := CaddyFile{
		path: path
	}
	mut file := pathlib.get_file(path: path, create: true)!
	content := file.read()!
	lines := content.split('\n')

	mut site_blocks := []SiteBlock{}
	mut current_site_block := SiteBlock{}
	mut in_site_block := false
	mut i := 0

	for i < lines.len {
		trimmed_line := lines[i].trim_space()
		if trimmed_line.starts_with('#') || trimmed_line.len == 0 {
			i++
			continue // Ignore comments and empty lines
		}

		if !in_site_block && trimmed_line.contains('{') {
			// Start of a new site block
			in_site_block = true
			address_line := trimmed_line.all_before('{').trim_space()
			if address_line.len > 0 {
				mut parts := address_line.split(',')
				
				for mut part in parts {
					part = part.trim_space()
					part_ := if !part.contains('://') {
						'http://${part}'
					} else {
						'${part}'
					}
					url := urllib.parse(part_)!
					current_site_block.addresses << Address{
						url: url
					}
				}
			}
			i++
			continue
		}

		if in_site_block {
			if trimmed_line.contains('}') {
				site_blocks << current_site_block
				current_site_block = SiteBlock{}
				in_site_block = false
				i++
				continue
			}

			if trimmed_line.len > 0 {
				directive, new_index := load_directive(lines, i)
				i = new_index
				current_site_block.directives << directive
				continue
			}
		}
		i++
	}

	caddyfile.site_blocks = site_blocks
	return caddyfile
}

fn load_directive(lines []string, index int) (Directive, int) {
	mut directive := Directive{}
	mut brace_count := 0
	mut i := index

	for i < lines.len {
		trimmed_line := lines[i].trim_space()
		println('trimmed_line ${trimmed_line} - ${directive}')

		if trimmed_line.starts_with('#') || trimmed_line.len == 0 {
			i++
			continue // Ignore comments and empty lines
		}
		
		if trimmed_line == '}' {
			return directive, i
		}

		if directive.name != '' {
			subdirective, new_index := load_directive(lines, i)
			println('debugzor- dir: ${directive.name} -- subdir: ${subdirective.name}')
			directive.subdirectives << subdirective
			i = new_index + 1
			continue
		}

		mut parts := trimmed_line.split(' ')
		directive.name = parts[0]
		directive.args = parts[1..]
		if trimmed_line.contains('{') {
			
			subdirective, new_index := load_directive(lines, i)
			println('debugzor- dir: ${directive.name} -- subdir: ${subdirective.name}')
			directive.subdirectives << subdirective
			i = new_index + 1
			continue
		} else {
			return directive, i + 1
		}

	}

	return directive, i
}
