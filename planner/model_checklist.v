module planner

pub struct Checklist {
pub mut:
	title string
	checks []ChecklistItem
}

pub struct ChecklistItem {
pub mut:
	description string
	name string
	deadline time.time
	
}

