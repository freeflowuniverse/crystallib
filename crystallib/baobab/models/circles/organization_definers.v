module circles

import rand

pub fn (mut circle Circle) define_epic(params Epic) ! {
	id := rand.uuid_v4()
	circle.epics[id] = params
}

pub fn (mut circle Circle) define_sprint(params Sprint) ! {
	id := rand.uuid_v4()
	circle.sprints[id] = params
}

pub fn (mut circle Circle) define_story(params Story) ! {
	id := rand.uuid_v4()
	circle.stories[id] = params
}

pub fn (mut circle Circle) define_task(params Task) ! {
	root_obj := circle.stories[params.story_id]
	root_obj.tasks << params
}
