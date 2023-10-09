# deploy dedicated servers

can be GPU on 3e party or as part of TFGrid.


```javascript

//look for 4 dedicated nodes, in line to selector... link them to vdc myvdc
!!vdc.dedicated_define vdc:'myvdc' name:'dedicated$nr' selector:'myselector' count:4
    image:'' //not always needed but e.g. for vast.io or other non 3fold provider might be needed

```

selectors are very flexible ways how to make a selection, see [selectors](selectors.md).

## how to deploy now on a dedicated server

```javascript


!!vdc.vm_define vdc:'myvdc' name:'web$nr'
    image:"despiegk/caddy1"  //is an image for caddy, which is a reverse proxy
    networks:'oob1'
    dedicated:'dedicated*'   //means we deploy on dedicated nodes starting with name dedicated e.g. dedicated1 could match
    count:'2'                //we install web1 and web2 , in other words 2 caddy's
```
