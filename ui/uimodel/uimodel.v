module uimodel

[params]
pub struct DropDownArgs {
pub mut:
	question    string // WARNING, this was changed to be question
	items       []string
	warning     string
	clear       bool = true
	all         bool
 	validation  fn (string) bool = fn (s string) bool {return true} // ? Is this valid?
}


pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	regex       string
	minlen      int
	reset       bool
	validation  fn (string) bool
}

pub struct YesNoArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool = true
	reset       bool
	validation  fn (string) string
}


