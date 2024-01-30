module tfrobot

import freeflowuniverse.crystallib.installers.tfgrid.tfrobot as tfrobot_installer

pub struct TFRobot {
pub mut:
	jobs map[string]Job
}

pub fn new() !TFRobot {
	tfrobot_installer.install()!
	return TFRobot{}
}
