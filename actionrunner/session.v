module actionrunner

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.console
import freeflowuniverse.crystallib.texttools
import time
import os

[heap]
pub struct SchedulerSession {
pub mut:
	name      string
	jobs      []ActionJob // all jobs
	gitrunner GitRunner
	fspath    string // actionrunner will use filesystem or not
}

// look for all actionrunner files in a dir and run them
pub fn (mut session SchedulerSession) run_from_dir(path string) ! {
	mut parser := actionparser.get()
	parser.add(path)!

	session.run_from_parser(mut parser)!
}

// parse the content and run it
pub fn (mut session SchedulerSession) run(content string) ! {
	mut parser := actionparser.get()
	parser.text_parse(content)!

	session.run_from_parser(mut parser)!
}

// creates folders necessary for actionrunner
fn (mut session SchedulerSession) setup_filesystem() {
	folders := ['init', 'tostart', 'recurring', 'scheduled', 'active', 'done', 'state', 'logs',
		'error']
	for folder in folders {
		os.mkdir_all(os.dir(@FILE) + '/example/filesystem/${folder}') or {
			panic('Cannot create dir: ${err}')
		}
	}
}

// loads scheduler session from filesystem
fn (mut session SchedulerSession) load_session(fspath string) {
	folders := ['init', 'tostart', 'recurring', 'scheduled', 'active', 'done', 'state', 'logs']
	for folder in folders {
		// os.mkdir_all(os.dir(@FILE) + '/example/filesystem/$folder')
	}
}

// loads actions from actionparser into session jobs
fn (mut session SchedulerSession) load_jobs(mut actions []actionparser.Action) ! {
	$if debug {
		println('Loading jobs...\n|')
	}

	for mut action in actions {
		$if debug {
			print(texttools.indent('${action}\n ', '|  '))
		}

		mut job := new_actionjob(action.name, action.params)
		job.load_state(state: .tostart)! // load the filesystem & state
		session.jobs << job
	}
}

// returns the actionjob's index in session jobs with given guid
fn (mut session SchedulerSession) get_actionjob(guid string) !int {
	for i, job in session.jobs {
		if job.guid == guid {
			return i
		}
	}
	return error('Failed to find job with guid: ${guid} in session.')
}

// handles returns from log and return channels
// if receives ActionJobReturn sets somethingtodo to true
fn (mut session SchedulerSession) listen_channels() !bool {
	// now select the channel to see which one has a return
	$if debug {
		eprint(texttools.indent(@FN + 'job actions select', '|  '))
	}

	mut somethingtodo := false
	if select {
		mut return_obj := <-session.gitrunner.channel_ret {
			// means runner emmited event and returned job
			// gets jobs' index in session.jobs in order to mutate in place
			mut job_index := session.get_actionjob(return_obj.job_guid)!
			session.jobs[job_index].handle_event(return_obj.event)!
			somethingtodo = true
		}
		git_log := <-session.gitrunner.channel_log {
			// ? Maybe the log listener should run concurrently, outside of the loop?
			$if debug {
				eprint(texttools.indent('LOG gitrunner:${git_log}', '|  '))
			}
			mut job_guid := git_log.split(':')[0]
			mut log_msg := git_log.split(':')[1]
			// ? should we use a job getter function here
			mut actionjob := ActionJob{
				guid: job_guid
			}
			actionjob.log(log_msg) // logs message to folder
		}
		500 * time.millisecond {
			// do something if no channel has become ready within 0.5s
			eprint(texttools.indent('> more than 0.5s passed without a channel being ready',
				'|  '))
		}
	} {
	} else {
		panic('all channels are closed')
	}
	return somethingtodo
}

fn (mut session SchedulerSession) run_from_parser(mut parser actionparser.ActionsParser) ! {
	session.setup_filesystem()
	session.load_jobs(mut parser.actions)!

	$if debug {
		println('Running scheduler session...')
	}

	mut somethingtodo := true
	for {
		if session.jobs.all(it.state == .done) {
			println('All jobs are done!')
			break
		}

		if somethingtodo == false {
			return error('we run out of things to do')
		}

		for mut job in session.jobs {
			$if debug {
				println('-- Scheduling job: ${job.actionname}, state: ${job.state}')
			}

			somethingtodo = false // now anything which is still something which needs to be done will put this on true
			somethingtodo = session.listen_channels()!

			if !job.check_dependencies_done() {
				// means this job is not ready to be processed yet
				continue
			}

			if job.dependencies_errors().len > 0 {
				// means one of the dependencies got in error
				errors := job.dependencies_errors()
				job.error('One of the dependencies has error.\n${errors}')
				continue
			}

			if job.state == .done {
				// means job is done
				continue
			}

			if job.state == .error {
				// means job is in error, nothing to do
				continue
			}

			if job.state == .init {
				// todo: define actions to be taken at init
				// todo: perhaps this shouldn't be in session loop, but handled before
			}

			if job.state == .tostart {
				// need to check timeout
				if !job.check_timeout_ok() {
					job.error('timeout on job in tostart state')
					continue
				}
				// pass job to runner, trigger schedule event
				job.handle_event(.schedule)!
				session.gitrunner.channel <- &job
				somethingtodo = true
				continue
			}

			if job.state == .scheduled {
				// means job is awaiting activation at the runner channel
				somethingtodo = true
				continue
			}

			if job.state == .active {
				// need to check timeout
				if !job.check_timeout_ok() {
					job.error('timeout on job in active state')
					continue
				}
				somethingtodo = true
				continue
			}
		} // end of walking over all jobs
	}

	return
}
