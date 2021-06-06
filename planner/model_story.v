module planner

import despiegk.crystallib.texttools

pub enum StoryStatus {
	suggested
	approved
	started
	verify
	closed
}

pub struct Story {
pub mut:
	name        string
	description string
	// path string
	// state        FileStatus
	owner        []string
	contributors []string
	// assignment []StoryAssign // someone works on the story or task, or bug, ...
}

// pub struct StoryAssign {
// pub mut:
// 	person     string
// 	group      string
// 	// membertype StoryAssignType
// 	expiration time.Time
// }

pub enum StoryLineState {
	start
	comment
	checklist
	task
}

fn (mut story Story) params_process(p texttools.Params) ? {
	println(p)
	panic('qq')
}

// load the lines into a story object
fn (mut story Story) load(lines []string) ? {
	mut headerlevel := 0
	for line in lines {
		println(' -- $line')
		argsfound, params := line_parser_params(line) ?
		if argsfound {
			story.params_process(params) ?
			continue
		}
	}
}
