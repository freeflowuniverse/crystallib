module publishermod

import texttools

fn iframe(state LineProcessorState, url string, params TextParams)? {

	mut width := params.get_int_default("width",800)
	mut height := params.get_int_default("height",450)

	if width < 200{
		width = 800
	}
	if height < 200{
		height = 450
	}
	if height > 2400{
		return error("height cannot be more than 2400")
	}	
	if width > 1600{
		return error("width cannot be more than 1600")
	}	

	if ! url.starts_with("http"){
		return error("url should start with http. $url. \n$params")
	}

	out := "<iframe src=\"$url\" width=\"$width\" height=\"$height\" frameborder=\"0\" allow=\"autoplay; fullscreen; encrypted-media\" allowfullscreen></iframe>"

	return true

}

fn vimeo(state LineProcessorState, id int, params TextParams)?string {
	if id < 10000{
		return error("vimeo id, corrupt, is $id, needs to be at least 10000. $params.")
	}
	return iframe(state,"https://player.vimeo.com/video/$id",params)
}


enum MacroState{
	macroname
	args
	kwargs
	ok
}

//if return true, means macro found
//format !!!$macroname $arg1 $arg2 
// arg's can be one or more, can also be $name:$val then keyvalue which will become params
// the args always need to come first
fn macro_process(state LineProcessorState, line string) bool{

	mut ms := MacroState{}
	mut macroname := ""
	mut args := []string{}
	mut kwargs := []string{}
	mut params := texttools.new_params()

	if !line.starts_with("!!!"){
		return false
	}
	splitted := line.split(' ')

	for item in splitted{

		if ms == MacroState.macroname{
			macroname = name_fix(item.trim("!").trim(":"))
			ms == MacroState.args
			continue
		}

		if ! (":" in item){
			//still arg
			args << item
			continue
		}

		ms == MacroState.kwargs

		if ms == MacroState.kwargs{
			if ! (":" in item){
				state.error("cannot have arg after kwarg, (means need ':' in kwarg: $line")
				return true
			}
			kwargs << item
		}
	}

	if kwargs.len >0{
		kwargs_line = kwargs.join(" ")
		params = texttools.text_to_params(kwargs_line) or {
			state.error('cannot process macro: $line.\n$err\n')
			return true
		}		
	}

	if macroname == "vimeo"{
		return vimeo(state, args[0].int(), params)
	}

	if macroname == "iframe"{
		return iframe(state, args[0], params)
	}	

	state.error('cannot find macro:$macroname in line:$line.')
	return true	

}
