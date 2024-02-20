
module podman

import json
import freeflowuniverse.crystallib.osal

@[params]
pub struct RunArgs {
pub mut:
	cmd string
	// TODO:/..
}

pub fn (mut self BContainer) run(args RunArgs) ! {
	// TODO
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
pub struct HeroInstall {
pub mut:
	reset bool
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
