module codemodel

// Code is a list of statements
pub type Code = []CodeItem

pub type CodeItem = Comment | Struct | Function | Sumtype

pub struct Comment {
	text string
	is_multi bool
}

pub struct Struct {
pub:
	name string
	description string
	fields []StructField
	mod string
}

pub struct Sumtype {
	pub:
	name string
	description string
	types []Type
}

pub struct StructField {
pub:
	comments []Comment
	attrs    []Attribute
	name string
	description string
	anon_struct Struct // sometimes fields may hold anonymous structs
	typ Type
}

pub struct Attribute {
pub:
	name    string // [name]
	has_arg bool
	arg     string // [name: arg]
}

pub struct Function {
pub:
	name         string
	receiver      Param 
	mod string
pub mut:
	description string
	params        []Param
	body           string
	result       Result
	has_return        bool
}

pub struct Param {
pub:
	required bool
	description string
	name string
	typ  Type
}

pub struct Result {
pub:
	typ Type
	description string
	name string
}

pub struct Type {
pub:
	symbol string	
}