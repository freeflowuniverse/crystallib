module data

//Data object for Task
pub struct Task {
pub mut:
	id          int
	name        string
	description string
	tags		[]string
	remarks		[]int
}