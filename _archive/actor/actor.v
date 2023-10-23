module actor

import freeflowuniverse.baobab.jobs

// This is the interface that represents an actor. It contains one attribute name
// which represents the name of the actor which will be used by the processor to put
// jobs in the right queue. It contains one function execute which is executed
// whenever the actor should execute a specific job. As you can see that function
// can fail. Making it fail will tell the actionrunner that the job failed.
pub interface IActor {
	name string
mut:
	execute(mut job jobs.ActionJob) !
}
