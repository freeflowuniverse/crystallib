# example definition our domain names

we still need to add DNS servers to our network, they are managed by a custom 3bot.

If name not specified on e.g dns.define a unique name will be created

```javascript

!!dns.domain_define name:'tf'
    domain:'threefold.io,threefold.me'
    vdc:'myvdc' //is always mapped to one or more vdc
    dnsserver:'tfgrid' //means we use tfgrid domain servers which is default
    

!!dns.define domain:'tf' record:'www:vm1' //means we point www.threefold.io and www.threefold.me to vm1 in vdc myvdc (port 443)
!!dns.define domain:'tf' record:'www:vm1:555,www:vm2:666,' //means we point www.threefold.io and ... to vm1 on port 555 and also vm2 on 666

//redirects
!!dns.define domain:'tf' redirect:'www2:www' //means we redirect www2.threefold.io to www.threefold.io
!!dns.define domain:'tf' redirect:'www3:www.incubaid.com' //means we redirect www3.threefold.io and www3.threefold.me to www.incubaid.com


```

If we define a domain the threefold domain server functionality will be useds, means records will be defined.

the webgateways as defined in the vdc will be used to configure these names and reverse proxy entries.

## customer runs on DNS servers


```javascript

!!dns.domain_define name:'tf_external'
    domain:'threefold.io,threefold.me'
    vdc:'myvdc' //is always mapped to one or more vdc
    dnsserver:'212.3.247.33,ns.something.com' //means we use external dns servers, can also just leave empty if not specified
    

!!dns.define domain:'tf' record:'www:vm1' //means we point www.threefold.io and www.threefold.me to vm1 in vdc myvdc (port 443)
!!dns.define domain:'tf' record:'www:vm1:555,www:vm2:666,' //means we point www.threefold.io and ... to vm1 on port 555 and also vm2 on 666

//redirects not supported because no control over DNS server

```

if dns servers defined, we will do a check if configuration done properly.

the webgateways as defined in the vdc will be used to configure these names and reverse proxy entries.