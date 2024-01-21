pub struct Step {
pub mut:
	name    string
	command string
	script  string [json: raw]
	output  string [json: 'output']
	depends []string [skip]
}

[heap]
struct DAG {
pub mut:
	name                string
	description         string
	steps []Step	
	schedule            string //in cron format
	group               string
	tags                string
	env                 map[string]string
	log_dir             string [json: 'logDir']
	restart_wait_sec    int    [json: 'restartWaitSec']
	hist_retention_days int    [json: 'histRetentionDays']
	delay_sec           int    [json: 'delaySec']
	max_active_runs     int    [json: 'maxActiveRuns']
	params              []string
	preconditions       []Precondition
	mail_on             MailOn [json: 'mailOn']
	max_clean_up_time_sec int  [json: 'MaxCleanUpTimeSec']
	handler_on          HandlerOn [json: 'handlerOn']
}

struct Precondition {
pub mut:	
	condition string
	expected  string
}

struct MailOn {
pub mut:	
	failure bool
	success bool
}

struct Handler {
pub mut:	
	command string
}

struct HandlerOn {
pub mut:	
	success Handler
	failure Handler
	cancel  Handler
	exit    Handler
}


// handlerOn:
//   failure:
//     command: notify_error.sh
//   exit:
//     command: cleanup.sh
// steps:
//   - name: A task
//     command: main.sh

