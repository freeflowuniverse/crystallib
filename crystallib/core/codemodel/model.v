module codemodel

// Code is a list of statements
// pub type Code = []CodeItem

pub type CodeItem = Comment | CustomCode | Function | Import | Struct | Sumtype

// item for adding custom code in
pub struct CustomCode {
	text string
}

pub struct Comment {
	text     string
	is_multi bool 
}

pub struct Struct {
pub mut:
	name        string
	description string
	mod         string
	is_pub      bool
	embeds		[]Struct
	generics	map[string]string
	attrs       []Attribute
	fields      []StructField
}

pub struct Sumtype {
pub:
	name        string
	description string
	types       []Type
}

pub struct StructField {
pub:
	comments    []Comment
	attrs       []Attribute
	name        string
	description string
	default     string
	is_pub      bool
	is_mut      bool
	is_ref      bool
	anon_struct Struct // sometimes fields may hold anonymous structs
	typ         Type
pub mut:
	structure Struct
}

pub struct Attribute {
pub:
	name    string // [name]
	has_arg bool
	arg     string // [name: arg]
}

pub struct Function {
pub:
	name     string
	receiver Param
	is_pub bool
	mod      string
pub mut:
	description string
	params      []Param
	body        string
	result      Result
	has_return  bool
}

pub struct Param {
pub:
	required    bool
	mutable     bool
	is_shared   bool
	is_optional bool
	description string
	name        string
	typ         Type
	struct_     Struct
}

pub struct Result {
pub:
	typ         Type
	description string
	name        string
	result      bool // whether is result type
	optional    bool // whether is result type
	structure   Struct
}

// todo: maybe make 'is_' fields methods?
pub struct Type {
pub:
	is_reference bool
	is_map       bool
	is_array     bool
	is_mutable   bool
	is_shared    bool
	is_optional  bool
	is_result    bool
	symbol       string
	mod          string
}

pub struct Import {
pub mut:
	mod   string
	types []string
}

pub struct Module {
	name    string
	files   []CodeFile
	model   CodeFile
	methods CodeFile
}
