# Caddy

## Install Caddy

```js

!!caddy.install
    xcaddy:true
    plugins:'github.com/mholt/caddy-webdav,github.com/mohammed90/caddy-git-fs'
    restart:true



```

details:

```go
reset     bool
start     bool
restart   bool
stop      bool
homedir   string
file_path string // path to caddyfile, if empty will install default one
file_url  string // path to caddyfile through e.g. git url, will pull it if it is not local yet
xcaddy bool      // wether to install caddy with xcaddy
plugins []string // list of plugins to build caddy with
```

## Configure Caddy




```js

//TODO: still wrong

!!caddy_configure.static
    id:'myconfig1' //corresponds to the @id in caddy
    path_cfg:'/etc/caddy' //where the config file will be
    url:''
    public_ip:''
    domain_name:''
    static:'' //for test purposes, can be e.g. hello world

!!caddy_configure.static
    id:'myconfig1' //corresponds to the @id in caddy
    path_cfg:'/etc/caddy' //where the config file will be
    url:''
    public_ip:''
    domain_name:''
    static:'' //for test purposes, can be e.g. hello world


```