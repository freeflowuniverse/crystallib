module data

//Data object for Issue
pub struct Issue {
pub mut:
	id          int
	name        string
	description string
	tags		[]string
	remarks		[]int
}