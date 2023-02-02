module ui

[params]
pub struct DropDownArgs {
pub mut:
	all         bool // means user can choose all of them
	description string
	items       []string
	warning     string
	reset       bool = true
}

[params]
pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	reset       bool = true
	regex       string
	minlen      int
}