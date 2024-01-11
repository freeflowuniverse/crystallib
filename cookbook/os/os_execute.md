
## easiest way how to execute something

```golang
import os

res:=os.execute("screen -ls")
if res.exit_code>0{
    return error("cannot execute screen.\n$res.output")
}

//the result of execute is:
struct Result {
	exit_code int
	output    string
}
```