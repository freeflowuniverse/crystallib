module project

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.baobab.models.system
import freeflowuniverse.crystallib.data.ourtime

pub struct Story {
	system.Base
pub mut:
	name             string
	project          system.SmartId           [root_object: Project]
	title            string
	description      string
	priority         Priority
	deadline         ourtime.OurTime
	effort_demaining int
	percent_done     f64
	owners           []string         [root_object: Person]
	assignment       []system.SmartId [root_object: 'Person, Team']
	state            State
	epics            []system.SmartId         [root_object: Epic]
	costcenters      []system.SmartId         [root_object: CostCenter]
	milestones       []system.SmartId [root_object: Milestone]
	requirements     []system.SmartId         [root_object: Requirement]
}

// pub enum StoryStatus {
// 	suggested
// 	approved
// 	started
// 	verify
// 	closed
// }

// pub struct Story {
// pub mut:
// 	name        string
// 	description string
// 	// path string
// 	state        StoryStatus
// 	owner        []string
// 	contributors []string
// 	assignment   []StoryAssign // someone works on the story or task, or bug, ...
// }

// pub struct StoryAssign {
// pub mut:
// 	person string
// 	group  string
// 	// membertype StoryAssignType
// 	expiration system.OurTime
// }

// pub enum StoryLineState {
// 	start
// 	comment
// 	checklist
// 	task
// }

// fn (mut story Story) params_process(p texttools.Params) ? {
// 	println(p)
// 	panic('qq')
// }

// // load the lines into a story object
// fn (mut story Story) text_load(lines []string) ? {
// 	mut headerlevel := 0
// 	mut state := StoryLineState.start
// 	mut checklists := Checklists{}
// 	mut comments := Comments{}
// 	lines << '# END'
// 	for line in lines {
// 		println(' -- ${line}')
// 		argsfound, params := line_parser_params(line)?
// 		if argsfound {
// 			story.params_process(params)?
// 			continue
// 		}
// 		if line.starts_with('#') {
// 			line2 := line[1..].trim(' ').to_lower()
// 			if line2.starts_with('comment') {
// 				state = StoryLineState.comment
// 				comments.new(line2) // get new comments
// 				continue
// 			}
// 			if line2.starts_with('checklist') {
// 				state = StoryLineState.checklist
// 				checklist := checklists.new(line2) // get new checklist
// 				continue
// 			}
// 		}
// 		// find the checklist
// 		if state == StoryLineState.checklist {
// 			if line.starts_with('#') {
// 				checklists.list_current_finish()
// 				state == StoryLineState.start
// 			} else {
// 				checklist.list_current_add(line)
// 				continue
// 			}
// 		}

// 		// find the comment
// 		if state == StoryLineState.comment {
// 			if line.starts_with('#') {
// 				comments.comment_current_finish()
// 				state == StoryLineState.start
// 			} else {
// 				comments.comment_current_add(line)
// 				continue
// 			}
// 		}
// 	}
// }
