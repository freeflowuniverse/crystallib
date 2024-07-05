module caddy

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os

pub fn (file CaddyFile) export() !string {
	// Load the existing file and merge it with the current instance
	existing_file := load_caddyfile(file.path) or {
		return error('Failed to load existing Caddyfile: ${err}')
	}
	merged_file := merge_caddyfiles(existing_file, file)

	content := merged_file.site_blocks.map(it.export(0)).join('\n')

	validate(text: content) or { return error('Caddyfile is not valid\n${err}') }
	return content
}

pub struct ValidateArgs {
	text string
	path string
}

pub fn validate(args ValidateArgs) ! {
	if args.text != '' && args.path != '' {
		return error('either text or path is required to validate caddyfile, cant be both')
	}
	if args.text != '' {
		job := osal.exec(
			cmd: "echo '${args.text.trim_space()}' | caddy validate --adapter caddyfile --config -"
		)!
		if job.exit_code != 0 || !job.output.trim_space().ends_with('Valid configuration') {
			return error(job.output)
		}
		return
	}
	return error('either text or path is required to validate caddyfile')
}

// Generates config for site in caddyfile
pub fn (block SiteBlock) export(indent_level int) string {
	indent := '\t'.repeat(indent_level)
	mut str := block.addresses.map(it.export(indent_level)).join(', ')
	directives_str := block.directives.map(it.export(indent_level + 1)).join('\n')
	return '${str} {\n${directives_str}\n${indent}}'
}

pub fn (directive Directive) export(indent_level int) string {
	indent := '\t'.repeat(indent_level)
	mut str := indent
	if directive.matchers.len > 0 {
		str += directive.matchers.map(it.export(indent_level + 1)).join('\n') + '\n'
	}
	str += directive.name
	if directive.args.len > 0 {
		str += ' ' + directive.args.join(' ')
	}
	// Export subdirectives
	if directive.subdirectives.len > 0 {
		str += ' {\n' + directive.subdirectives.map(it.export(indent_level + 1)).join('\n') +
			'\n${indent}}'
	}
	return str
}

pub fn (matcher Matcher) export(indent_level int) string {
	indent := '\t'.repeat(indent_level)
	return '${indent}${matcher.name} ${matcher.args.join(' ')}'
}

pub fn (addr Address) export(indent_level int) string {
	indent := '\t'.repeat(indent_level)
	mut str := ''
	if addr.description != '' {
		str = '${indent}${addr.description}\n'
	}

	if addr.url.str() != '' {
		str += '${indent}${addr.url.str()}'
	}
	return str
}

// Function to merge two CaddyFile instances
fn merge_caddyfiles(existing CaddyFile, new_file CaddyFile) CaddyFile {
	mut merged_file := existing
	for block in new_file.site_blocks {
		merged_file.add_site_block(block)
	}
	return merged_file
}
