# RMBProxy

meant to be installed on a server with public ip address.

For now its kind of shortcut to get things to work


## message format

- encode from crystal lib
- use: add_map_bytes  (keys are the parts)

## messages

### job.send (map: key = cmd)

- rmbclient sends to rmbproxy or reverse
- actionname = job.send
- data map: 
    - cmd: "job.send"
    - twinid: ...
    - signature: bytes for ed25519 signed with priv key twin who sends
    - payload: encrypted jsonserialized for job see ActionJobPublic of rmbclient, encrypted with pubkey dest twin
- purpose: send job to destination of proxy
- guid will go to queue: rmb.jobs.clients.$rmbclientid


### twin.set

- rmbclient sends to rmbproxy
- sends the TwinMetaPub
- store TwinMetaPub in local redis (see client)
- if twin received has ID higher than the highest, update in DB
- data map: 
    - cmd: "twin.set"
    - meta: non encrypted data blob: TwinMetaPub

### twin.del

- ... 


## twin.get

- rmbclient asks proxy info from client based on id
- data map: 
    - cmd: "twin.get"
    - meta: non encrypted data blob: TwinMetaPub

## twinid.new

- rmbclient asks proxy for next free id, e.g. if rmbclient has not identified himself het
- proxy checks peer proxies (if any), and will make sure that id given is the highest and will inform others

## proxies.get

- return list of known active proxies

