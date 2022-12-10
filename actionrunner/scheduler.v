module actionrunner

import freeflowuniverse.crystallib.actionparser
import freeflowuniverse.crystallib.console
import freeflowuniverse.crystallib.texttools
import time


//the main process which coordinate alls
[heap]
pub struct Scheduler {
pub mut:
	sessions map[string]SchedulerSession
	logger console.Logger
}

[heap]
pub struct SchedulerSession {
pub mut:
	name string
	// jobs Jobs //needs to be shared between threads 
	jobs []ActionJob 	//all jobs
	gitrunner GitRunner	
	filesystem bool // actionrunner will use filesystem or not
}

pub fn scheduler_new() Scheduler {
	return Scheduler{}
}

// // load runners checks runner file content and loads necessary runners into scheduler
// fn (mut scheduler Scheduler) load_runners(name string) !SchedulerSession{

// }


fn (mut scheduler Scheduler) session_new(name string) !SchedulerSession{
	scheduler.sessions[name] = SchedulerSession{name:name}
	mut session := scheduler.sessions[name]
	mut gitrunner := new_gitrunner()
	session.gitrunner = gitrunner
	go gitrunner.run()

	// mut booksrunner := new_booksrunner()
	// session.channels["books"] = gitrunner
	// go booksrunner.run()

	time.sleep(200 * time.millisecond) //wait 0.2 sec to make sure its operational

	return session
}

fn (mut scheduler Scheduler) session_get(name string) !SchedulerSession{
	//TODO: more checks
	if !scheduler.sessions.keys().contains('name') {
		return error("Session with name '$name' not found.")
	}
	return scheduler.sessions[name]
}


//look for all actionrunner files in a dir and run them
pub fn (mut session SchedulerSession) run_from_dir(path string)! {

	mut parser := actionparser.get()
	parser.add(path)!

	session.run_from_parser(mut parser)!
}


//parse the content and run it
pub fn (mut session SchedulerSession) run(content string)! {

	mut parser := actionparser.get()
	parser.text_parse(content)!

	session.run_from_parser(mut parser)!
}

fn (mut session SchedulerSession) run_from_parser(mut parser actionparser.ActionsParser)! {

	$if debug {
		println('Loading actions...\n|')
	}

	for mut action in parser.actions {
		$if debug {
			print(texttools.indent('$action\n ', '|  '))
		}

		mut job := ActionJob{
			actionname : action.name
			params : action.params
			start : time.now()
			id : u32(session.jobs.len + 1)
			state: .init
		}
		
		//load the jobs
		session.jobs << job

	}

	$if debug {
		println('Running scheduler...')
	}

	mut somethingtodo := true
	for {

		if session.jobs.all(it.state == .ok) {
			println('All jobs are done!')
			break
		}

		if somethingtodo == false{
			return error("we run out of things to do")
		}

		for mut job in session.jobs {
			$if debug {
				println('-- Scheduling job: $job.actionname, state: $job.state')
			}

			somethingtodo=false //now anything which is still something which needs to be done will put this on true

			$if debug {
				eprint(texttools.indent(@FN + 'job actions select', '|  '))
			}

			//now select the channel to see which one has a return
			if select {
				//! This causes scheduler to receive back it's own job (without sleep)
				//? Can we keep this channel unidirectional?
				// git_obj := <- session.gitrunner.channel {
				// 	println("GIT CHANNEL RETURN")
				// 	println(git_obj)
				// 	panic("s17")
				// 	somethingtodo = true
				// }
				git_log := <- session.gitrunner.channel_log {
					// ? is id always index + 1?
					mut job_index := git_log.split(':')[0].int()-1
					mut log_msg := git_log.split(':')[1]

					$if debug {
						eprint(texttools.indent('LOG gitrunner:action$git_log', '|  '))
						somethingtodo = true
					}

					// todo: separate channel for state updates?
					session.jobs[job_index].update_state(log_msg)! 	
				}		
				500 * time.millisecond {
					// do something if no channel has become ready within 0.5s
					eprint(texttools.indent('> more than 0.5s passed without a channel being ready', '|  '))

				}	
				// b = <- session.channels["books"]  {
				// 	// do something with predeclared variable `b`
				// 	eprintln('> b: ${b}')
				// }
			} {} else {
				panic('all channels are closed')
			}

			if ! job.check_dependencies_done(){
				//means this job is not ready to be processed yet
				continue
			}

			if job.dependencies_errors().len>0{
				//means one of the dependencies got in error
				errors:=job.dependencies_errors()
				job.error("One of the dependencies has error.\n$errors")
				continue
			}

			if job.state == .ok{
				//means job is done
				continue
			}

			if job.state == .error{
				$if debug {eprintln(@FN + 'job error')}
				//means job is in error, nothing to do
				continue
			}

			if job.state == .init{
				$if debug {eprint(texttools.indent(@FN + 'job init', '|  '))}
				if job.actionname.starts_with('git.') {
					$if debug {eprint(texttools.indent(@FN + 'job init git', '|  '))}
					job.state_tostart(ToStartArgs{})!
					// eprintln(session.gitrunner.channel)
					session.gitrunner.channel <- &job
					$if debug {eprint(texttools.indent(@FN + 'job init git done', '|  '))}
					//now we can continue with next job
					somethingtodo=true
					continue
				}else{
					$if debug {eprintln(@FN + 'no action')}
					job.error("cannot find action for job.")
					continue
				}
			}
			
			if job.state == .tostart{
				$if debug {eprintln(@FN + 'job tostart')}
				//need to check timeout
				if ! job.check_timeout_ok(){
					job.error("timeout on job in tostart state")
					continue
				}				
				somethingtodo=true
				continue
			}

			if job.state == .active{
				$if debug {eprintln(@FN + 'job active')}
				//need to check timeout
				if ! job.check_timeout_ok(){
					job.error("timeout on job in active state")
					continue
				}		
				somethingtodo=true		
				continue
			}

		}//end of walking over all jobs
	}

	return 
}



