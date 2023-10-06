module main

import os
import freeflowuniverse.crystallib.bizmodel
import cli { Command, Flag }

// const wikipath = os.dir(@FILE) + '/wiki'

fn do() ! {
	mut cmd := Command{
		name: 'bizmodel'
		description: 'Run your bizmodel.'
		version: '1.0.0'
	}
	mut run_cmd := Command{
		name: 'run'
		description: 'Run 1 simulation.'
		usage: 'summary_path -i /data/mybizmodelwiki -o /tmp/outputdir'
		required_args: 1
		execute: run_func
	}

	run_cmd.add_flag(Flag{
		flag: .string
		required: false
		name: 'summarydir'
		abbrev: 's'
		description: 'location of the summary file'
	})

	run_cmd.add_flag(Flag{
		flag: .string
		required: false
		name: 'outputdir'
		abbrev: 'o'
		description: 'where the html will be generated, is optional'
	})

	run_cmd.add_flag(Flag{
		flag: .string
		required: false
		name: 'inputdir'
		abbrev: 'i'
		description: 'path to the collections, can be more than 1'
	})

	cmd.add_command(run_cmd)
	cmd.setup()
	cmd.parse(os.args)
}

fn run_func(cmd Command) ! {
	inputdir := cmd.flags.get_string('inputdir') or { os.getwd() }

	summarydir := cmd.flags.get_string('summarydir') or {
		dir := os.getwd()
		if !os.exists('${dir}/summary.md') {
			return error('Failed to find summary.md in current directory. Try passing directory that hosts summary.md file with the summarydir flag.')
		}
		dir
	}

	outputdir := cmd.flags.get_string('outputdir') or { '/tmp/bizmodel/output' }

	// mut c := context.new()!

	mut book := bizmodel.new(
		name: 'example'
		mdbook_name: 'biz_book'
		mdbook_path: summarydir // TODO: need to make sure we support collections not to be on same place as summary
		mdbook_dest: outputdir
		path: inputdir
	)!

	book.read()! // will generate and open	
}

fn main() {
	do() or { panic(err) }
}
