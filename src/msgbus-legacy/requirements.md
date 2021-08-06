
# secure message bus

- works with DTWIN id's & name's
  - caching of DTWIN obj in redis
  - if not in cache use the client of tfgrid db
- timeout on command
- checks
  - cannot deliver
  - delivery did not start in time
  - did not return in time
  - returned but as error
- using planetary network
  - check if planetary network is using multiple access points (reliability)
  
  