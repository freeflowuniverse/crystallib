# Jobs

The word job has been mentioned a few times already. One can describe a job as the information needed by an actor to do a specific thing (compute something, produce a specific result on a system, bring an actor in a specific state, etc).

In baobab a job contains the attributes:
- *guid*: a unique id for this job
- *twinid*: the twinid of the system that contains the actor that can execute this job
- *action*: a name for the job which should be unique across all actors, it should follow the structure domain.actor.action
- *args*: the arguments that the actor requires in order to execute that job
- *result*: the result(s) that we expect to get once the job is executed
- *state*: the current state of the job
- *error*: in case something went wrong the error message
- *timeout*: the timeout for the job
- *src_twinid*: the twinid of the one requesting the execution of the job

The baobab package contains a struct defining a job which is used by the actors, the actionrunner and the processor. It contains the implementation on how to encode and decode jobs so that they can be stored in redis and send to other systems. 

To execute the job from another system you should send an RMB message with the json stringyfied job as payload to the twinid of the system that can execute the job. The command of the RMB message should be *execute_job*. You should put it into the queue *msgbus.system.local*, the rmb peer will take care of sending the message to the right system. The job will be returned with the results if everything went well.