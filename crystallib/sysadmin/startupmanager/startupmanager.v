module startupmanager

import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.osal.systemd

pub enum StartupManagerType {
	screen
	zinit
	tmux
	systemd
}

pub struct StartupManager {
pub mut:
	cat StartupManagerType
}

pub struct StartupManagerArgs {
pub mut:
	cat StartupManagerType
}

pub fn get() !StartupManager {
	mut sm := StartupManager{}
	if systemd.check()! {
		sm.cat = .systemd
	}
	return sm
}

pub struct StartArgs {
pub mut:
	description string
	name        string            @[requred]
	cmd         string
	reset       bool
	restart		bool = true// whether the process should be restarted on failure
	env         map[string]string

	// start  bool = true
	// attach bool
}

// launch a new process
//```
// name  string
// cmd   string
// reset bool
//```
pub fn (mut sm StartupManager) start(args StartArgs) ! {
	console.print_debug("startupmanager start:${args.name} cmd:'${args.cmd}' reset:${args.reset}")
	match sm.cat {
		.screen {
			mut scr := screen.new(reset: false)!
			console.print_debug('  screen')
			_ = scr.add(name: args.name, cmd: args.cmd, reset: args.reset)!
		}
		.systemd {
			if args.reset {
				
			}
			console.print_debug('  systemd')
			mut systemdfactory := systemd.new()!
			systemdfactory.new(
				cmd: args.cmd
				name: args.name
				description: args.description
				start: true
				restart: args.restart
				env: args.env
			)!
		}
		else {
			panic('to implement, startup manager only support screen & systemd for now')
		}
	}
}

// kill the process by name
pub fn (mut sm StartupManager) stop(name string) ! {
	match sm.cat {
		.screen {
			mut screen_factory := screen.new(reset: false)!
			mut scr := screen_factory.get(name) or { return }
			scr.cmd_send('^C')!
			screen_factory.kill(name)!
		}
		.systemd {
			console.print_debug('  systemd')
			mut systemdfactory := systemd.new()!
			mut systemdprocess := systemdfactory.get(name)!
			systemdprocess.stop()!
		}
		else {
			panic('to implement, startup manager only support screen for now')
		}
	}
}

// remove from the startup manager
pub fn (mut sm StartupManager) delete(name string) ! {
	match sm.cat {
		.screen {
			mut screen_factory := screen.new(reset: false)!
			mut scr := screen_factory.get(name) or { return }
			scr.cmd_send('^C')!
			screen_factory.kill(name)!
		}
		.systemd {
			mut systemdfactory := systemd.new()!
			mut systemdprocess := systemdfactory.get(name)!
			systemdprocess.delete()!
		}
		else {
			panic('to implement, startup manager only support screen & systemd for now')
		}
	}
}

pub enum ProcessStatus {
    unknown
    active
    inactive
    failed
    activating
    deactivating
}

// remove from the startup manager
pub fn (mut sm StartupManager) status(name string) !ProcessStatus {
	match sm.cat {
		.screen {
			mut screen_factory := screen.new(reset: false)!
			mut scr := screen_factory.get(name) or { return error('process with name ${name} not found') }
			match scr.status()! {
				.active {return .active}
				.inactive {return .inactive}
				.unknown {return .unknown}
			}
		}
		.systemd {
			mut systemdfactory := systemd.new()!
			mut systemdprocess := systemdfactory.get(name) or {
				return .unknown
			}
			systemd_status := systemdprocess.status() or {
				return .unknown
			}
			return ProcessStatus.from(systemd_status.str())
		}
		else {
			panic('to implement, startup manager only support screen & systemd for now')
		}
	}
}

// remove from the startup manager
pub fn (mut sm StartupManager) output(name string) !string {
	match sm.cat {
		.screen {
			panic('implement')
		}
		.systemd {
			return systemd.journalctl(service: name)!
		}
		else {
			panic('to implement, startup manager only support screen & systemd for now')
		}
	}
}

pub fn (mut sm StartupManager) exists(name string) !bool {
	match sm.cat {
		.screen {
			mut scr := screen.new(reset: false) or { panic("can't get screen") }
			return scr.exists(name)
		}
		.systemd {
			mut systemdfactory := systemd.new()!
			return systemdfactory.exists(name)
		}
		else {
			panic('to implement. startup manager only support screen & systemd for now')
		}
	}
}

// list all services as known to the startup manager
pub fn (mut sm StartupManager) list() ![]string {
	match sm.cat {
		.screen {
			mut scr := screen.new(reset: false) or { panic("can't get screen") }
			panic('implement')
		}
		.systemd {
			mut systemdfactory := systemd.new()!
			return systemdfactory.names()
		}
		else {
			panic('to implement. startup manager only support screen & systemd for now')
		}
	}
}

// THIS IS PROBABLY PART OF OTHER MODULE NOW

// pub struct SecretArgs {
// pub mut:
// 	name string     @[required]
// 	cat  SecretType
// }

// pub enum SecretType {
// 	normal
// }

// // creates a secret if it doesn exist yet
// pub fn (mut sm StartupManager) secret(args SecretArgs) !string {
// 	if !(sm.exists(args.name)) {
// 		return error("can't find screen with name ${args.name}, for secret")
// 	}
// 	key := 'secrets:startup:${args.name}'
// 	mut redis := redisclient.core_get()!
// 	mut secret := redis.get(key)!
// 	if secret.len == 0 {
// 		secret = rand.hex(16)
// 		redis.set(key, secret)!
// 	}
// 	return secret
// }
