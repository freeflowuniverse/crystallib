# how to deploy docker workloads

if dockers are used on a VM it will use docker based ubuntu 22.04 image with VLang environment pre-installed.

the docker building/deploying happens by means of sal in V Crystallib

```javascript
!!vdc.docker_new vdc:'myvdc' name:'gitea' 
    vm:'containerhost'
    tcp_ports:'888:80,889:443'  //map outside 888 to inside 80, 889 to 443
    init:'/bin/aprocess'
    build:1                    //if build set, it will build it from scratch once initialzed
    
!!vdc.docker_mount_new vdc:'myvdc' docker:'gitea' name:'m1_code' 
    vm_path:'/code'
    host_path:'/code'

!!vdc.docker_mount_new vdc:'myvdc' docker:'gitea' name:'m1_data' 
    vm_path:'/root/data'
    host_path:'/gitea/data'

    
```

## build from a heroscript

```javascript

!!vdc.image_define vdc:'myvdc' name:'mybuild' 
    vm:'containerhost'
    build_heroscript:'https://raw.githubusercontent.com/threefoldtech/3bot/development/myheroscript.v'
    image_name:'myimage'
```

above will execute the heroscript from the defined location, this needs to result in a local image with name 'myimage'

## build from a V Build script

```javascript

!!vdc.docker_define vdc:'myvdc' name:'mybuild' 
    vm:'containerhost'
    tcp_ports:'888:80,889:443'  //map outside 888 to inside 80, 889 to 443
    build_heroscript:'https://raw.githubusercontent.com/threefoldtech/3bot/development/mybuild.v'
    image_name:'myimage2'
```

A v build script (examples see vbuilder) will be used to build the container. The vscript needs to result in a local image with name 'myimage2'

Because it's not deleted, the result will be a live docker container mapped in VM on ports 888 and 889.
