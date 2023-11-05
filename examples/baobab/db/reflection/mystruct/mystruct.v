module mystruct

import freeflowuniverse.crystallib.baobab.db
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.paramsparser

import json
import time

pub struct MyStruct {
	db.Base
pub mut:
	nr      int
	color   string
	nr2     int
	listu32 []u32
}
