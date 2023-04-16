module main

import freeflowuniverse.crystallib.openrpc
import freeflowuniverse.crystallib.openrpc.docgen
import freeflowuniverse.crystallib.pathlib

import cli { Command, Flag }
import json
import os

fn main() {
	mut cmd := Command{
		name: 'openrpc'
		description: 'OpenRPC Library CLI'
		version: '1.0.0'
	}
	mut docgen_cmd := Command{
		name: 'docgen'
		description: 'Generates docs for a given OpenRPC Client Module in V'
		usage: '<client_path>'
		required_args: 1
		execute: cli_docgen
	}
	docgen_cmd.add_flag(Flag{
		flag: .string
		required: true
		name: 'title'
		abbrev: 't'
		description: 'Title of the OpenRPC Document.'
	})
	docgen_cmd.add_flag(Flag{
		flag: .string
		name: 'version'
		abbrev: 'v'
		default_value: ['1.0.0']
		description: 'OpenRPC Version of the document.'
	})
	docgen_cmd.add_flag(Flag{
		flag: .string
		name: 'output_path'
		abbrev: 'o'
		default_value: ['.']
		description: 'Path the OpenRPC client will be created at.'
	})
	docgen_cmd.add_flag(Flag{
		flag: .string
		name: 'description'
		abbrev: 'd'
		description: 'Description of the OpenRPC Document'
	})

	cmd.add_command(docgen_cmd)
	cmd.setup()
	cmd.parse(os.args)
}

fn cli_docgen(cmd Command) ! {
	config := docgen.OpenRPCConfig{
		title: cmd.flags.get_string('title') or { panic('Failed to get `title` flag: $err') }
		description: cmd.flags.get_string('description') or { panic('Failed to get `description` flag: $err') }
		version: cmd.flags.get_string('version') or { panic('Failed to get `version` flag: $err') }
		source: cmd.args[0]
	}
	doc := docgen.docgen(config) or {panic('Failed to generate OpenRPC Document.\n$err')}
	target := cmd.flags.get_string('output_path') or { panic('Failed to get `output_path` flag: $err') }
	doc_str := json.encode(doc)

	mut target_path := ''
	if target == '.' {
		target_path = os.getwd() + '/openrpc.json'
	}

	os.write_file(target_path, doc_str)!
}