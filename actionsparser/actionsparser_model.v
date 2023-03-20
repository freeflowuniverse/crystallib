module actionsparser

pub struct ActionsParser {
pub mut:
	unsorted []Action // should be empty after filter action
	ok       []Action // the ones ready to be processed they are in order
	error    []Action // the ones who are in error
	skipped  []Action // the ones which won't be processed because its not right book or even actor
	actor    string
	book     string
	filter   []string
}
