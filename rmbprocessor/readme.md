# RMBProcessor

works with the local redis and does the forwarding to rmb proxy and does some healthchecks


## there are 2 subthreads

- one doing the websocket stuff rom the rmb proxy (messages back and forward)
   - this thread will use redis queue (see rmb client how to do that with rpoll, ...), you can use channels too
   - this is to send the rmb proxies to a queue so the main loop can process incoming messages
   - it will check queue as driven from main loop, so messages can go to rmb proxy
- subthread for management of local redis (the forwarding toward proxy, ...)

