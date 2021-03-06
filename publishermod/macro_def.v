module publishermod

import despiegk.crystallib.texttools

fn macro_def(mut state LineProcessorState, mut macro texttools.MacroObj, mut publisher Publisher, mut page Page) ? {
	mut categories := macro.params.get_list('category') ?
	mut defname2 := macro.params.get_default('name',"") ?
	//defname not defined, will get the title as the definition name
	if defname2 == "" {
		defname2 = page.title()
	}

	if defname2 == "" {
		return error("could not find name of the definition in the page.")
	}

	page.categories_add(categories)

	mut defobj := Def{}

	if defname2 in publisher.defs {
		// println(publisher.defs[defname2])
		defobj = publisher.defs[defname2]
		page_def_double := publisher.page_get_by_id(defobj.pageid) ?
		{
			panic('cannot find page by id')
		}
		state.error('duplicate definition: $defname2, already exists in $page_def_double.name')
	} else {
		defobj = Def{
			pageid: page.id
			name: defname2
		}
		publisher.defs[defname2] = defobj
	}	

	defobj.categories_add(categories)

	println(defobj)

	panic("s")


}

fn macro_def_list(mut state LineProcessorState, mut macro texttools.MacroObj, mut publisher Publisher, mut page Page) ? {
	mut categories := macro.params.get_list('category') ?

}