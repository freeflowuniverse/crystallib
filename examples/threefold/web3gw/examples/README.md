# Examples

Before running examples make sure the server is running:

```shell
cd ../server
go build && ./server --debug
```


See the subfolder for all examples available for implemented clients.

## Adding new examples

You can use the file [template.v](template.v) as a template. Don't modify it though! The CI will build all v scripts inside the examples folder. CI should always be green so that we make sure that development builds at all times. 
