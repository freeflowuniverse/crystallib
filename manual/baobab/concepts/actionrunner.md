# ActionRunner

As mentioned in the introduction actors can ask other actors to execute jobs. Ofcourse, as an actor you don't really care where the other actor is running, nor how it is running, nor how you can contact that other actor. You know its name, the jobs it can execute and the information that actor requires for each job. How it executes the jobs, you don't care. In order to achieve the don't cares we introduced the actionrunner. 

The actionrunner is the entity that distributes the jobs to the right actors. It allows you to pass a list of actors that you want to run on your system. It will know which actor should execute what job and it will initialize the execution of the job. The actionrunner does that by constantly checking the actors' redis queue (formatted as *jobs.actors.$domain_name.$actor_of_actor*). Whenever one of those queues contains a job it will execute the execute function of that actor. If that function properly returns the actionrunner will return the response to a response queue (*jobs.processor.result*). In the other case it will return it to the error queue (*jobs.processor.error*). 

The baobab package contains an implementation for the actionrunner in V. If you wish to implement an actor in another language you will need to reimplement that class in that language.

You might have asked yourself the question: "How do jobs get into the queues of the actors?". To get an answer to that question let's read the next chapter.