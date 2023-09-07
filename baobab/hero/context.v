
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.baobab.spawner
import freeflowuniverse.crystallib.bizmodel

//this is nr of factory classes we might need depending the context
pub struct Context {
pub mut:
	path     	 pathlib.Path // is the base directory of the runner
	gitstructure ?gittools.GitStructure
	spawner 	 ?spawner.Spawner
	bizmodel	 map[string]bizmodel.BizModel

}




pub fn (mut c Context) init(script3 string) ! {