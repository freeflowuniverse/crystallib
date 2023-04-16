module codemodel

// Code is a list of statements
pub type Code = []CodeItem

pub type CodeItem = Comment | Struct | Function

pub struct Comment {
	text string
	is_multi bool
}

pub struct Struct {
	pub:
	name string
	fields []StructField
}

pub struct StructField {
	pub:
	comments []Comment
	attrs    []Attribute
	name string
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
pub mut:
	description string
	params        []Param
	body           string
	result       Result
	has_return        bool
}

pub struct Param {
	pub:
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