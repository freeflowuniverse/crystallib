module events

struct Event {
	msg string
	// dot notation
	cat      string
	priority EventPriority
	severity EventSeverity
	epoch    int
}

// what is the priorty in which the event needs to be dealt with
// default not known and does not have to be filled in by ZOS
// unless there is a good reason for it e.g. temperature becoming too high
enum EventPriority {
	unknown
	critical
	high
	normal
	low
}

// how serious is the event (event)
enum EventSeverity {
	unknown
	critical
	high
	normal
	low
}
