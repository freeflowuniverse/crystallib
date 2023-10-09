# Processor

Baobab needs one more component in order to have a fully working actor model architecture: the processor. The processor is in charge of moving the jobs to the right queues based on its state.

The processor will follow these guidelines:

- if the job is in init state pass it to the actionrunner
- if we received a job from outside our system pass it to the actionrunner
- if the timeout has exceeded it will return an error
- if the job resulted in an error it will return the error
- if the actionrunner properly returned the job it will return it

## How
Just as the actionrunner the processor will monitor a couple of queues.

*jobs.processor.in* is the queue of incoming jobs. These are the jobs that are meant for the system where the processor is running. The processor will move the job to the queue of the actor that has to run the job. Those queues are formatted as *jobs.actors.$domain_name.$actor*. From previous chapter we know that the actionrunner will handle those queues. 

The actionrunner will put the failed jobs in the queue *jobs.processor.error*. The processor will pop the jobs from that queue, modify the state to failed and return it to the queue *jobs.return.$guid*.

The successful jobs will be put in the queue *jobs.processor.result* by the actionrunner. The processor will pop those jobs, modify to the state accordingly and return it to the queue *jobs.return.$guid*.

The processor is also in charge of initiating the execution of jobs received from outside the system it is running on. The processor is able to receive jobs via RMB. This introduces one extra depencendy: the system should be running the [rmb-peer](https://github.com/threefoldtech/rmb-rs/releases). If you wish to read more about RMB you should go through [this documentation](https://github.com/threefoldtech/rmb-rs/tree/main/docs). The rmb-peer will put the jobs it receives from outside the system in the queue *msgbus.execute_job*. The processor will handle those jobs the same way as it would coming from the incoming jobs queue.
