## ping

```go
assert ping(address:"338.8.8.8")==.unknownhost
assert ping(address:"8.8.8.8")==.ok
assert ping(address:"18.8.8.8")==.timeout
```

will do a panic if its not one of them, an unknown error

## platform

```go
if platform()==.osx{
    //do something
}

pub enum PlatformType {
	unknown
	osx
	ubuntu
	alpine
}

pub enum CPUType {
	unknown
	intel
	arm
	intel32
	arm32
}

```

//TODO: do more documentation
//URGENT: fix the tests, we had to refactor some