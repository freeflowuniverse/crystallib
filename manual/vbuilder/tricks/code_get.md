
## get code from repository

Its best not to manually get code from a gitrepo, but use this snippet

```golang
r.add_codeget(url:'git@github.com:kairoaraujo/goca.git',dest:'/code/goca')!

r.add_run(
	cmd: '
	cd /code/goca/rest-api
	go build -o main .
	cp main /bin/goca
	'
)!
```

the code wil get checked out locally in the build dir and then added to /code/... (the dest)

This is way more reliable than doing it inside the container and can use our VLANG constructs, e.g. deal with ssh git access and our ssh-keys

