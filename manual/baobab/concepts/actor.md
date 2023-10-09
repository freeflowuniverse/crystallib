# Actor

An actor can be seen as an entity that is able to do some work and that can asynchronously communicate with other actors. It can ask any other actor for some information which it needs in order to do the work it has to do. This is very much how we work together as human beings. We ask a colleague to do some work that we need in order to do our work. But we don't wait for the result until we actually need it. This is one of the requirements of an Actor in an actor-model based architecture:

* Everything is an actor
* Actors can execute jobs
* Actors can ask other actors to execute jobs
* Actors communicate with each other using messages
* Actors don't know how to call other actors directly
* Actors can have a state

The baobab package contains an interface of an Actor that defines one function: execute. Upon exection this function tells the actor to execute a specific job. Baobab knows the job was a success once that function properly returns and will act accordingly.

One of the many benefits of the actor model principle is that you can implement an actor in any language you want. This means you will have to recreate the Actor interface and implement your actor in the language you want.

Once you have one or more actors it's time to connect them using what we call an ActionRunner. This will be discussed in the next chapter.