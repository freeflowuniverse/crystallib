# RMBClient

this is what needs to be re-developed for other languages, we kept it as easy as possible


## there can be more than 1 client

- when a client registers it choses a name
- the client for information purposes also populates a hset with actor coordinates (domain.actor.method) can be e.g. only domain or domain + actor or even domain + actor + method (just put in hset)
    - this is used by the RMBprocessor to route what needs to be done by the actor
    - the client needs to specify the queue names on which the client listens
- I can also work as client, not being an actor, just a client

