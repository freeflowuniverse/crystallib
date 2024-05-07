module scheduler

import baobab.seeds.schedule { Calendar }
import freeflowuniverse.crystallib.baobab.backend { FilterParams }

// creates the Calendar with the given object id
pub fn (mut actor Scheduler) create_calendar(calendar Calendar) !int {
	return actor.backend.new[Calendar](calendar)!
}

// gets the calendar with the given object id
pub fn (mut actor Scheduler) read_calendar(id string) !Calendar {
	return actor.backend.get[Calendar](id)!
}

// gets the Calendar with the given object id
pub fn (mut actor Scheduler) update_calendar(calendar Calendar) ! {
	actor.backend.set[Calendar](calendar)!
}

// deletes the Calendar with the given object id
pub fn (mut actor Scheduler) delete_calendar(id int) ! {
	actor.backend.delete[Calendar](id)!
}

// lists all of the calendar objects
pub fn (mut actor Scheduler) list_calendar() ![]Calendar {
	return actor.backend.list[Calendar]()!
}

struct FilterCalendarParams {
	filter CalendarFilter
	params FilterParams
}

struct CalendarFilter {
pub mut:
	tag string
}

// lists all of the calendar objects
pub fn (mut actor Scheduler) filter_calendar(filter FilterCalendarParams) ![]Calendar {
	return actor.backend.filter[Calendar, CalendarFilter](filter.filter, filter.params)!
}
