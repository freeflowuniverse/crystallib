## Macro's

A macro is an object with following interface

```v

pub interface IMacroProcessor {
mut:
	process(code string) !MacroResult
}

pub struct MacroResult {
pub mut:
	result string
	error  string
	state  MacroResultState
}


pub enum MacroResultState {
	ok
	error
	stop
}

//example

pub fn my_macro(code string) !MacroResult{

    //now something which processes the code e.g. finds the actions inside

}


```
