module uimodel

[params]
pub struct DropDownArgs {
pub mut:
	description string
	items       []string
	warning     string
	clear       bool = true
}


pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	regex       string
	minlen      int
}

pub struct YesNoArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
}


