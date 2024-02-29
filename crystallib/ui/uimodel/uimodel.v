module uimodel

@[params]
pub struct DropDownArgs {
pub mut:
	description    string
	question       string
	items          []string
	default        []string
	warning        string
	clear          bool
	all            bool
	choice_message string
	validation     fn (string) bool = fn (s string) bool {
		return true
	}
}

@[params]
pub struct QuestionArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool
	regex       string
	minlen      int
	reset       bool
	default     string
	validation  fn (string) bool = fn (s string) bool {
		return true
	}
}

// validation responds with either true or an error message

@[params]
pub struct YesNoArgs {
pub mut:
	description string
	question    string
	warning     string
	clear       bool
	reset       bool
	default     bool
	validation  fn (string) bool = fn (s string) bool {
		return true
	}
}

@[params]
pub struct LogArgs {
pub mut:
	content   string
	clear     bool // means screen is reset for content above
	lf_before int  // line feed before content
	lf_after  int
	cat       LogCat
}

// defines colors as used in the representation layer
pub enum LogCat {
	info
	log
	warning
	header
	debug
	error
}

@[params]
pub struct InfoArgs {
pub mut:
	content    string // in specified format
	clear      bool   // means screen is reset for content above
	lf_before  int    // line feed before content
	lf_after   int
	cat        InfoCat
	components []ComponentCat
}

// defines colors as used in the representation layer
pub enum InfoCat {
	txt
	html
	markdown
}

// MORE THAN ONE COMPONENT CAN BE ADDED TO INFO
pub enum ComponentCat {
	bootstrap
	htmx
	bulma
}

@[params]
pub struct EditArgs {
pub mut:
	content string // in specified format
	cat     EditorCat
}

// defines colors as used in the representation layer
pub enum EditorCat {
	txt
	markdown
	heroscript
}

@[params]
pub struct PayArgs {
pub mut:
	amount   f64
	currency string = 'USD' // use currency module to do conversions where needed,
	// TODO: what else do we need
}
