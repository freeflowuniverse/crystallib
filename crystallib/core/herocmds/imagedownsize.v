module herocmds

import freeflowuniverse.crystallib.tools.imagemagick
import cli { Command, Flag }
import os

// const wikipath = os.dir(@FILE) + '/wiki'

pub fn cmd_imagedownsize(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'image_downsize'
		description: 'walk over current director or specified one and downsize all images'
		required_args: 0
		execute: cmd_imagedownsize_execute
	}

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'path'
		abbrev: 'p'
		description: 'If not in current directory.'
	})

	cmd_run.add_flag(Flag{
		flag: .string
		required: false
		name: 'backupdir'
		abbrev: 'b'
		description: 'What is the backup dir if any.'
	})	

	cmdroot.add_command(cmd_run)
}

fn cmd_imagedownsize_execute(cmd Command) ! {

	mut backupdir := cmd.flags.get_string('backupdir') or { '' }
	mut path := cmd.flags.get_string('path') or { '' }
	if path==""{
		path=os.getwd()
	}
	imagemagick.downsize(path:path,backupdir:backupdir) or { 
			print_backtrace()
			print(err)
			panic(err) 
		}	
}
