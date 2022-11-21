module actionrunner

import freeflowuniverse.crystallib.actionparser
import time


//the main process which coordinate alls
[heap]
pub struct Scheduler {
pub mut:
	sessions map[string]SchedulerSession
}

[heap]
pub struct SchedulerSession {
pub mut:
	name string
	// jobs Jobs //needs to be shared between threads 
	jobs []ActionJob 	//all jobs
	gitrunner GitRunner	
}



pub fn scheduler_new() Scheduler {
	return Scheduler{}
}


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
	return scheduler.sessions[name]
}

//parse the content and run it
fn (mut session SchedulerSession) run(content string)! {

	mut parser := actionparser.get()
	parser.text_parse(content)!

	// $if debug {
	// 	println("+++++")
	// 	println(actions)
	// 	println("-----")
	// }

	for mut action in parser.actions {
		$if debug {
			println(' --------ACTION:\n$action\n--------')
		}

		mut job := ActionJob{
			actionname : action.name
			params : action.params
			start : time.now()
			id : u32(session.jobs.len + 1)
		}
		
		//load the jobs
		session.jobs << job

	}
	for {
		mut somethingtodo := true
		for mut job in session.jobs {


			if somethingtodo==false{
				return error("we run out of things to do")
			}

			somethingtodo=false //now anything which is still something which needs to be done will put this on true

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
				$if debug {eprintln(@FN + 'job ok')}
				//means job is done
				continue
			}
			if job.state == .error{
				$if debug {eprintln(@FN + 'job error')}
				//means job is in error, nothing to do
				continue
			}

			
			if job.state == .init{
				$if debug {eprintln(@FN + 'job init')}
				if job.actionname.starts_with('git.') {
					$if debug {eprintln(@FN + 'job init git')}
					job.state_scheduled()!
					eprintln(session.gitrunner.channel)
					session.gitrunner.channel <- &job
					$if debug {eprintln(@FN + 'job init git done')}
					//now we can continue with next job
					somethingtodo=true
					
					continue
				}else{
					$if debug {eprintln(@FN + 'no action')}
					job.error("cannot find action for job.")
					continue
				}
			}
			
			if job.state == .scheduled{
				$if debug {eprintln(@FN + 'job scheduled')}
				//need to check timeout
				if ! job.check_timeout_ok(){
					job.error("timeout on job in scheduled state")
					continue
				}				
				somethingtodo=true
				continue
			}

			if job.state == .running{
				$if debug {eprintln(@FN + 'job running')}
				//need to check timeout
				if ! job.check_timeout_ok(){
					job.error("timeout on job in running state")
					continue
				}		
				somethingtodo=true		
				continue
			}

			// } else if action.name.starts_with('books.') {
			// 	msg := ActionJob{
			// 		name: action.name
			// 		params: action.params
			// 	}
			// 	booksrunner.channel <- msg
			// 	for {
			// 		res := <-booksrunner.channel
			// 		if res.name == msg.name && res.params == msg.params && res.complete {
			// 			break
			// 		}
			// 	}
			// }else{
			// 	msg := ActionJob{
			// 		name: action.name
			// 		params: action.params
			// 	}
			// 	booksrunner.channel <- msg
			// 	for {
			// 		res := <-booksrunner.channel
			// 		if res.name == msg.name && res.params == msg.params && res.complete {
			// 			break
			// 		}
			// 	}
			// }

			//now select the channel to see which one has a return
			$if debug {eprintln(@FN + 'job actions select')}
			select {
				git_obj := <- session.gitrunner.channel {
					println("GIT CHANNEL RETURN")
					println(git_obj)
					panic("s17")
					somethingtodo=true
				}
				git_log := <- session.gitrunner.channel_log {
					println("GIT LOG RETURN")
					println(git_log)
					panic("ssdsd")
					somethingtodo=true
				}			
				// b = <- session.channels["books"]  {
				// 	// do something with predeclared variable `b`
				// 	eprintln('> b: ${b}')
				// }
			}			

		}//end of walking over all jobs

		time.sleep(50 * time.millisecond) {
			eprintln(' > more than 0.5s passed without a channel being ready')
		}	
	}

	return 
}



