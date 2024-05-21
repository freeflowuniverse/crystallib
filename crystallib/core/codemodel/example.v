module codemodel

pub struct Example {
	function Function
	values map[string]Value
	result Value
}

pub type Value = string