# Circle

> TODO: not good yet, need quite some change

- has a unique CID = circle id (is a SID)
- has following components
  - context 
    - manages a state for one specific context
    - has a name and unique cid, and is linked to 1 circle (there can be more than 1 in a circle)
    - has params 
    - has todo checklist
  - session
    - linked to 1 context
    - has unique id (int) linked to context
    - can have a name (optional)
    - is like a chat session, can be any series of actions
    - each action once in needs to be executed becomes a job
    - a job is linked to a heroscript, which is the physical representation of all the jobs (actions) which need to be executed, the heroscript is in order.
    - each action done on session is stateless in memory (no mem usage), in other words can pass Session around without worrying about its internal state
    - we use redis as backend to keep the state
  - job
    - linked to a session
    - has incremental id, in relation to session
    - is the execution of 1 specific action (heroscript action)
    - action can go to SAL,DAL or WAL
    - it results in logs being collected
    - it results in params being set on session level (only when WAL)
    - TODO: needs to be implemented on job (Kristof)