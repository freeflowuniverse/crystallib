# how to attach SSH keys

```javascript

!!vdc.sshkey_define vdc:'myvdc' name:'kristof' 
    sshkey:'aaaadd'

!!vdc.sshkey_define vdc:'myvdc' name:'someone' 
    sshkey:'aaaaaaa'

```

One or more keys can be attached to a VDC.

If not specified or overruled on VM level then the VM will add all SSH keys as specified on VDC level.