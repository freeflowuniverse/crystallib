module perfectuniverse

// the state how you want the universe to be
struct RetryPolicy {
	name  string = 'default'
	retry []int  = [1, 1, 1, 1, 10, 30, 60, 90, 180, 300, 300, 300, 600, 600, 600, 600, 600, 3600,
	3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600,
	3600, 3600, 3600]
}

struct WishList {
	name           string
	retry_policies []RetryPolicy
	startwish      Wish
pub mut:
	// what is the last known state when we did a last check
	state StateEnum
	// last time we checked dependencies
	check_last int
}

pub enum DayIdentifier {
	weekdays
	weekend
	monday
	tuesday
	wednesday
	thursday
	friday
	saturday
	sunday
	sunday1
	sunday2
	sunday3
	sunday4
	firstmonthday
	lastmonthday
}

struct Availability {
	days_recurring []DayIdentifier
	// in dd/mm/yyyy or dd/mm/yy or dd/mm then same year or +10d  (minimum is 1 day)
	days_onetime []string
	// 0...24, 0 is midnight
	hour_start int
	hour_stop  int
	// 0 means cannot be used, 100% means in period all can be used
	availability_percent i8
}

struct Resource {
	name         string
	description  string
	category     ResourceCategory
	availability []Availability
	twinid       int
}

pub enum ResourceCategory {
	person
	node
}

struct Wish {
	// name of the wish, what do you want the system to be, each wish needs to have a unique name
	name string
	// we need to know the category because this defines which wish type to load e.g. install a package, or apply a network config, ...
	category CategoryEnum
	// action e.g. exists for git, or push for git, or install for cmd
	action string
	// a system to allow us to search for wishes, its free style catergorization
	tags        []string
	description string
	// who will execute and what are the limits
	assigned         string
	retrypolicy_name string = 'default'
	// name of other perfect wishes we depend on, this wish will not be executed before dependencies are ok
	dependencies []string
	// deadline before it needs to be in ok mode, format e.g. +10h or 30/11/2021, if +10h then will be converted automatically to the right date in HR
	deadline string
	// if set will not start before mentioned time, format e.g. +10h or 30/11/2021, if +10h then will be converted automatically to the right date in HR
	start string
	// effort in hours for the wish to be done, is an estimate e.g 1h, 1d, 1m, 0.5m, 0.1y
	effort string
pub mut:
	// what is the last known state when we did a last check
	state StateEnum
	// last time we checked dependencies
	check_last int
	// how often do you want to check the dependencies on changes
	check_period int
}

pub enum StateEnum {
	unknown
	ok
	error
}

pub enum CategoryEnum {
	story
	task
	package
	gitrepo
	app
	docker
	kubernetes
	network
}
