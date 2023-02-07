module uimodel

[params]
pub struct DropDownArgs {
pub mut:
	description string
	items       []string
	warning     string
	clear       bool = true
	all bool
}


pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	regex       string
	minlen      int
	reset bool
}

pub struct YesNoArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	reset bool
}


