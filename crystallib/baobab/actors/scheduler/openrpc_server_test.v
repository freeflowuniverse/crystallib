module scheduler

const port = 3000

pub fn test_wsserver() ! {
	spawn run_wsserver(scheduler.port)
}
