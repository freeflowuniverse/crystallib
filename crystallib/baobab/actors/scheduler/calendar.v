module scheduler

import baobab.seeds.schedule { Calendar }
import freeflowuniverse.crystallib.baobab.backend { FilterParams }

// news the Calendar with the given object id
pub fn (mut actor Scheduler) new_calendar(calendar Calendar) !string {
	return actor.backend.new[Calendar](calendar)!
}

// gets the calendar with the given object id
pub fn (mut actor Scheduler) get_calendar(id string) !Calendar {
	return actor.backend.get[Calendar](id)!
}

// gets the Calendar with the given object id
pub fn (mut actor Scheduler) set_calendar(calendar Calendar) ! {
	actor.backend.set[Calendar](calendar)!
}

// deletes the Calendar with the given object id
pub fn (mut actor Scheduler) delete_calendar(id string) ! {
	actor.backend.delete[Calendar](id)!
}

pub struct CalendarList {
	items []Calendar
}

// lists all of the calendar objects
pub fn (mut actor Scheduler) list_calendar() !CalendarList {
	return CalendarList{
		items: actor.backend.list[Calendar]()!
	}
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
