module planner

pub enum StoryStatus {
	suggested
	approved
	started
	verify
	closed
}

pub struct Story {
pub mut:
	name string
	path string
	// state        FileStatus
	assignment []int // someone works on the story or task, or bug, ...
}
