# Params

```v
import freeflowuniverse.crystallib.data.paramsparser

mut p:=paramsparser.new('
    id:a1 name6:aaaaa
    name:'need to do something 1' 
)!

assert "a1"==p.get_default("id","")!


```

example text to parse

```yaml
id:a1 name6:aaaaa
name:'need to do something 1' 
description:
    ## markdown works in it

    description can be multiline
    lets see what happens

    - a
    - something else

    ### subtitle


name2:   test
name3: hi name10:'this is with space'  name11:aaa11

#some comment

name4: 'aaa'

//somecomment
name5:   'aab' 
```

results in

```go
Params{
    params: [Param{
        key: 'id'
        value: 'a1'
    }, Param{
        key: 'name6'
        value: 'aaaaa'
    }, Param{
        key: 'name'
        value: 'need to do something 1'
    }, Param{
        key: 'description'
        value: '## markdown works in it

                description can be multiline
                lets see what happens
                
                - a
                - something else
                
                ### subtitle
                '
		}, Param{
			key: 'name2'
			value: 'test'
		}, Param{
			key: 'name3'
			value: 'hi'
		}, Param{
			key: 'name10'
			value: 'this is with space'
		}, Param{
			key: 'name11'
			value: 'aaa11'
		}, Param{
			key: 'name4'
			value: 'aaa'
		}, Param{
			key: 'name5'
			value: 'aab'
		}]
	}
```

