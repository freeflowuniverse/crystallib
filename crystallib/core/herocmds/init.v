module herocmds

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.lang.crystallib
import freeflowuniverse.crystallib.installers.db.redis as redisinstaller
import freeflowuniverse.crystallib.ui.console
import cli { Command, Flag }

pub fn cmd_init(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'init'
		usage: '
Initialization Helpers for Hero

-r will reset everything e.g. done states (when installing something)
-d will put the platform in development mode, get V, crystallib, hero...
-c will compile hero on local platform (requires local crystallib)

'
		description: 'initialize hero environment (reset, development mode, )'
		required_args: 0
		execute: cmd_init_execute
	}

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'reset'
		abbrev: 'r'
		description: 'will reset.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'develop'
		abbrev: 'd'
		description: 'will put system in development mode.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'compile'
		abbrev: 'c'
		description: 'will compile hero.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'redis'
		description: 'will make sure redis is in system and is running.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_init_execute(cmd Command) ! {
	mut develop := cmd.flags.get_bool('develop') or { false }
	mut reset := cmd.flags.get_bool('reset') or { false }
	mut hero := cmd.flags.get_bool('compile') or { false }
	mut redis := cmd.flags.get_bool('redis') or { false }

	println(hero)

	if redis {
		base.install()!
		redisinstaller.install()!
		return
	}

	if develop {
		base.install(reset: reset,develop:true)!
		return
	}
	if hero {
		base.install(reset: reset,develop:true)!
		crystallib.hero_compile()!
		r := osal.profile_path_add_hero()!
		console.print_header(' add path ${r} to profile.')
		return
	}

	return error(cmd.help_message())
}
