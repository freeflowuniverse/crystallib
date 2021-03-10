module publishermod

import despiegk.crystallib.texttools

fn macro_def(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut categories := macro.params.get_list('category') ?
	categories << macro.params.get_list('categories') ?
	// println(categories)
	mut defname2 := macro.params.get_default('name',"") ?
	//defname not defined, will get the title as the definition name
	if defname2 == "" {
		defname2 = state.page.title()
	}else{
		defname2 = defname2.replace("_"," ")
	}

	if defname2 == "" {
		return error("could not find name of the definition in the page.")
	}

	state.page.categories_add(categories)

	mut defobj := Def{
		pageid: state.page.id
		name: defname2		
	}

	defname2 = name_fix_no_underscore(defname2)

	mut aliasses :=  macro.params.get_list('alias') ?
	for mut alias in aliasses {
		alias = name_fix_no_underscore(alias)

		if alias in state.publisher.defs {
			println(" >>> ALIAS $alias")
			page_def_double_page_id := state.publisher.defs[alias].pageid
			page_def_double := state.publisher.page_get_by_id(page_def_double_page_id) or
			{
				// println(state.publisher.pages)
				panic('cannot find page by id: $page_def_double_page_id\n')
			}
			state.error('duplicate definition: $defname2, already exists in $page_def_double.name')
		} else {
			state.publisher.defs[alias] = defobj
		}		
	}

	defobj.categories_add(categories)

	// println(defobj)

}

fn macro_def_list(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut categories := macro.params.get_list('category') ?
	println(categories)
	panic("s")

}