module codemodel

import freeflowuniverse.crystallib.core.pathlib
// Code is a list of statements
// pub type Code = []CodeItem

pub type CodeItem = Alias | Comment | CustomCode | Function | Import | Struct | Sumtype

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
	embeds      []Struct @[str: skip]
	generics    map[string]string @[str: skip]
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
pub mut:
	comments    []Comment
	attrs       []Attribute
	name        string
	description string
	default     string
	is_pub      bool
	is_mut      bool
	is_ref      bool
	anon_struct Struct @[str: skip] // sometimes fields may hold anonymous structs
	typ         Type
	structure Struct @[str: skip]
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
	is_pub   bool
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
pub mut:
	is_reference bool @[str: skip]
	is_map       bool @[str: skip]
	is_array     bool @[str: skip]
	is_mutable   bool @[str: skip]
	is_shared    bool @[str: skip]
	is_optional  bool @[str: skip]
	is_result    bool @[str: skip]
	symbol       string
	mod          string @[str: skip]
}



pub struct Import {
pub mut:
	mod   string
	types []string
}

pub fn parse_import(code_ string) Import {
	code := code_.trim_space()
	types_str := if code.contains(' ') {code.all_after(' ').trim('{}')} else {''}
	return Import{
		mod: code.all_before(' ')
		types: if types_str != '' { 
			types_str.split(',').map(it.trim_space())
		} else {[]string{}}
	}
}

pub struct File {
	name string
	extension string
	content string
}

pub fn (f File) write(path string) ! {
	mut fd_file := pathlib.get_file(path: '${path}/${f.name}.${f.extension}')!
	fd_file.write(f.content)!
}

pub struct Alias {
	pub:
	name        string
	description string
	typ Type
}