module circles

import time

@[root_object]
pub struct Calendar {
	title string
}

@[root_object]
pub struct Event {
	title       string
	description string
	category    string
}
