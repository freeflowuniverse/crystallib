# baobab manual

It's always good practice to make your software do one thing only and do it well. This results in less complex code that is easier to maintain. So instead of having one application that is able to do 5 totally different things it is better to develop 5 different applications. If one of those applications need the help of another it can always ask. In the meantime it can continue its work until the other application is done helping. 

This introduction is a basic decription of the [actor model principles](https://www.oreilly.com/library/view/scala-reactive-programming/9781787288645/8253d31d-ed61-46c3-8c69-9d49d8d8ab07.xhtml). I just used different names in my example. You can rename applications by actors and "help of another application" by "executing jobs". There are many benefits to using that model, here are a few:

* Loosely coupled code: actors don't need to know about other actors (where they are, what they do, how they do it)
* Improves scalibility: we can quickly add new instances of an actor if need be
* Improves availability: if one actor goes down it will not drag down other actors down
* Less complex code: actors handle specific tasks which means that there are no longer situations where an actor does many different things.
* Choice of language: one actor can be written in C, another in V an yet another in Python. That's all possible. This allows the developer to choose which language is better suited to implement the required behavior.
* Distributed: actors don't have to run on the same system which allows for distribution and helps towards decentralisation.

The baobab package was created to facilitate applying the actor model principles to your codebase. It is implemented in [V](https://vlang.io/) and contains many interfaces and classes in order to quickly implement the components required in an actor-based model. If you wish to implement an actor in another language you can always translate the required components. Which components you should translate will be mentioned further in the manual.