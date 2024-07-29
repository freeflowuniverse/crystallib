
# CoreDNS

see /root/code/github/freeflowuniverse/crystallib/crystallib/installers/infra/coredns/coredns_play.v

## Install CoreDNS

```js
!!coredns.install
    //TODO: are these right plugins lets test with some
    plugins:'github.com/coredns/alternate,github.com/coredns/federation'
    restart:true
```

details:

```js
reset   bool    //this means we re-install and forgot what we did before
start   bool = true
stop   bool
restart bool     //this means we stop if started, otherwise just start
homedir   string //not sure what this is?
config_path string // path to Corefile, if empty will install default one
config_url  string // path to Corefile through e.g. git url, will pull it if it is not local yet
dnszones_path string //path to where all the dns zones are
dnszones_url string //path on git url pull if needed
plugins []string // list of plugins to build CoreDNS with
example bool   // if true we will install examples
```

## Configure CoreDNS for zones & forward

//TODO: needto create configurator

```js
!!coredns.configure_zone
    id:'myzone1' // corresponds to the zone name in CoreDNS
    zone:'example.com'
    file:'/etc/coredns/db.example.com'

!!coredns.configure_forward
    id:'myforward1' // corresponds to the forward plugin in CoreDNS
    from:'.'
    to:'8.8.8.8 8.8.4.4'
```


## Configure CoreDNS Zone Information

```js
!!coredns.configure_zone
    id:'myzone1'
    zone:'example.com'
    file:'/etc/coredns/db.example.com'
    ttl:3600

!!coredns.configure_soa
    zone:'example.com'
    mname:'ns1.example.com.'
    rname:'hostmaster.example.com.'
    serial:'2023062001'
    refresh:7200
    retry:3600
    expire:1209600
    minttl:3600

!!coredns.configure_ns
    zone:'example.com'
    name:'ns1.example.com.'

!!coredns.configure_ns
    zone:'example.com'
    name:'ns2.example.com.'

!!coredns.configure_mx
    zone:'example.com'
    priority:10
    host:'mail1.example.com.'

!!coredns.configure_mx
    zone:'example.com'
    priority:20
    host:'mail2.example.com.'

!!coredns.configure_a
    zone:'example.com'
    name:'@'
    ip:'192.168.1.1'

!!coredns.configure_a
    zone:'example.com'
    name:'www'
    ip:'192.168.1.2'

!!coredns.configure_aaaa
    zone:'example.com'
    name:'@'
    ip:'2001:db8::1'

!!coredns.configure_aaaa
    zone:'example.com'
    name:'www'
    ip:'2001:db8::2'

!!coredns.configure_cname
    zone:'example.com'
    name:'ftp'
    target:'www.example.com.'

!!coredns.configure_txt
    zone:'example.com'
    name:'@'
    text:'"v=spf1 include:_spf.example.com ~all"'

!!coredns.configure_srv
    zone:'example.com'
    name:'_sip._tcp'
    priority:10
    weight:60
    port:5060
    target:'sip.example.com.'

!!coredns.configure_ptr
    zone:'1.1.168.192.in-addr.arpa.'
    name:'1'
    target:'www.example.com.'
```