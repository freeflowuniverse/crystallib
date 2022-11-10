### To run the tests you have to follow the instructions

There are more than interface we use, every interface has its requirements
- RMB, HTTP and WebSocket


---
* HTTP:
    - You have to run the [http server](https://github.com/threefoldtech/grid3_client_ts), [read docs](https://github.com/threefoldtech/grid3_client_ts/blob/development/docs/rmb_server.md).
    - Must provide the enviroment varibale of which interface you using, then run the server and go through with the tests .e.g.
        ```bash
            $ export TWIN_CLIENT_TYPE=http
            $ v test twinclient/tests/
        ```

* RMB:
    - You have to run the [rmb server](https://github.com/threefoldtech/grid3_client_ts), [read docs](https://github.com/threefoldtech/grid3_client_ts/blob/development/docs/rmb_server.md).
    - You have to run redis server.
    - You have to run the [rmb_go](https://github.com/threefoldtech/rmb_go) server.
    - Must provide the enviroment varibale of which interface you using, then go through with the tests .e.g.
        ```bash
            $ export TWIN_CLIENT_TYPE=rmb
            $ v test twinclient/tests/
        ```

---
There are [examples](https://github.com/freeflowuniverse/crystallib/tree/development/twinclient/examples), you can run it to get more information about the interfaces life cycle.
