module podman

import json
import freeflowuniverse.crystallib.osal

@[params]
pub struct RunArgs {
pub mut:
	cmd string
	// TODO:/..
}

@[params]
pub struct PackageInstallArgs {
pub mut:
	names string
	// TODO:/..
}

// TODO: mimic osal.package_install('mc,tmux,git,rsync,curl,screen,redis,wget,git-lfs')!

// pub fn (mut self BContainer) package_install(args PackageInstallArgs) !{
// 	//TODO
// 	names := texttools.to_array(args.names)
// 	//now check which OS, need to make platform function on container level so we know which platform it is
// 	panic("implement")
// }

@[params]
pub struct Command {
pub mut:
	name               string // to give a name to your command, good to see logs...
	cmd                string
	description        string
	timeout            int  = 3600 // timeout in sec
	stdout             bool = true
	stdout_log         bool = true
	raise_error        bool = true // if false, will not raise an error but still error report
	ignore_error       bool // means if error will just exit and not raise, there will be no error reporting
	work_folder        string // location where cmd will be executed
	environment        map[string]string // env variables
	ignore_error_codes []int
	scriptpath         string // is the path where the script will be put which is executed
	scriptkeep         bool   // means we don't remove the script
	debug              bool   // if debug will put +ex in the script which is being executed and will make sure script stays
	shell              bool   // means we will execute it in a shell interactive
	retry              int
	interactive        bool = true
	async              bool
	runtime            RunTime
}

pub enum RunTime {
	bash
	python
	heroscript
	v
}

pub fn (mut self BContainer) run(cmd Command) ! {
	scriptpath := osal.cmd_to_script_path(cmd: cmd_)
	self.copy(scriptpath, scriptpath)!
	cmd_str := 'buildah run ${self.id} "${scriptpath} && rm -f ${scriptpath}"'
	osal.exec(
		name: cmd.name
		cmd: cmd_str
		description: cmd.description
		timeout: cmd.timeout
		stdout: cmd.stdout
		stdout_log: cmd.stdout_log
		raise_error: cmd.raise_error
		ignore_error: cmd.ignore_error
		ignore_error_codes: cmd.ignore_error_codes
		scriptpath: cmd.scriptpath
		scriptkeep: cmd.scriptkeep
		debug: cmd.debug
		shell: cmd.shell
		retry: cmd.retry
		interactive: cmd.interactive
		async: cmd.async
	)!
}

@[params]
pub struct HeroInstall {
pub mut:
	reset bool
}

pub fn (mut self BContainer) copy(src string, dest string) ! {
	cmd := 'buildah copy ${self.id} ${src} ${dest}'
	osal.exec(cmd: cmd)!
}

pub fn (mut self BContainer) hero_install(args HeroInstall) ! {
	// TODO: check hero is already there, only redo if reset=true
	panic('implement')
}

@[params]
pub struct HeroExecute {
pub mut:
	heroscript string
}

pub fn (mut self BContainer) hero_execute(args HeroInstall) ! {
	self.hero_install()!
	// TODO: copy heroscript to the container and ask hero to run the heroscript
	panic('implement')
}

// TODO: add all other relevant possibilities of what can be done on a buildah container
