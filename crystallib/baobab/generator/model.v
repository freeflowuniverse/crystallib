module generator

import freeflowuniverse.crystallib.core.codemodel {Struct, Module, Function}
import os

pub struct ActorGenerator {
	model_name string
}

pub struct Actor {
pub:
	name string
	mod Module
	methods []ActorMethod
	objects []BaseObject
}

pub struct ActorMethod {
pub:
	name string
	func Function
}

pub struct BaseObject {
	structure Struct
}