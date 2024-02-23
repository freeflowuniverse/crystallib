module herocmds

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.db.redis as redisinstaller
import freeflowuniverse.crystallib.ui.console
import cli { Command, Flag }

pub fn cmd_init(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'init'
		usage: '
Initialization Helpers for Hero

-r will reset everything e.g. done states (when installing something)
-d will put the platform in development mode, get V, crystallib, ...
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
	mut hero := cmd.flags.get_bool('hero') or { false }
	mut redis := cmd.flags.get_bool('redis') or { false }

	if develop || hero || redis {
		base.install()!
	}

	if redis {
		redisinstaller.install()!
	}

	if develop || hero {
		base.develop(reset: reset)!
	}
	if hero {
		base.hero_compile()!
		r := osal.profile_path_add_hero()!
		console.print_header(' add path ${r} to profile.')
	}

	return error(cmd.help_message())
}
