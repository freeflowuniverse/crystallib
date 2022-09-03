module publisher

import freeflowuniverse.crystallib.texttools

fn iframe(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut width := macro.params.get_int_default('width', 800)?
	mut height := macro.params.get_int_default('height', 450)?

	url := macro.params.get('url')?

	if width < 200 {
		width = 800
	}
	if height < 200 {
		height = 450
	}
	if height > 2400 {
		return error('height cannot be more than 2400 \n$macro')
	}
	if width > 1600 {
		return error('width cannot be more than 1600 \n$macro')
	}

	if !url.starts_with('http') {
		return error('url should start with http. ${url}. \n$macro')
	}

	out := "<iframe src=\"$url\" width=\"$width\" height=\"$height\" frameborder=\"0\" scrolling=\"no\" align=\"center\" allow=\"autoplay; fullscreen; encrypted-media\" allowfullscreen></iframe>"

	// [photos genesis pool](structure/images_threefold_genisispool_dubai.html ':include :type=iframe width=100% height=550px frameBorder="0" scrolling="no" align="center"')

	state.lines_server << out
}

fn vimeo(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	id := macro.params.get_int('id')?
	if id < 10000 {
		return error('vimeo id, corrupt, is $id, needs to be at least 10000. ${macro.params}.')
	}
	url := 'https://player.vimeo.com/video/$id'
	macro.params.kwarg_add('url', url)
	iframe(mut state, mut macro)?
}

fn youtube(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	id := macro.params.get('id')?
	url := 'https://www.youtube.com/embed/$id'
	macro.params.kwarg_add('url', url)
	iframe(mut state, mut macro)?
}
