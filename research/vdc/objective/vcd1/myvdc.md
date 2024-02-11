# example definition of our datacenter

is a mix of markdown and heroscript, is super easy to define.


```javascript
!!vdc.new name:myvdc
    description:'
        # my VDC 
        
        We can add multiline descriptions to it
        ' 

!!vdc.webgateway_define vdc:'myvdc' name:'gw$nr' 
    farm:'10,20,40'     //means we add to 2 known farms on TFGrid, its possible to have gateway active on more than 1 location
    country:'be,nl,de' 
    count:2
    description:''   //is optional, and can be added to every object

!!vdc.vm_define vdc:'myvdc' name:'vm$nr' 
    mem:'4GB' //supported gb,mb is case insensitive, spaces ignored (default 4GB)
    vcpu:4    //1 is minimal, max 64 (default 2)
    fssize:'20GB' //defaults ... (default a certain calculation in line to size, TBD)
    disks:'vm1_disk_root,vm1_disk_code'
    ipv6_pub:true              //default false
    ipv4_pub:1                 //true or 1 or True all same, default false
    planetary:true             //default true
    yggrasil:true              //defaulf false
    image:"despiegk/ubuntu22.04"  //is also the default
    tfhub:aname                   //default is the main hub of threefold
    networks:'internalnet1,oob1'
    node:'19,222'                //can be more than 1 node, will then use as name vm1 and vm2

!!vdc.vm_define vdc:'myvdc' name:'web$nr'
    image:"despiegk/caddy1"  //is an image for caddy, which is a reverse proxy
    networks:'oob1'
    farm:'1,2'              //will deploy on farm 1 and 2, we will not choose a specific node
    sshkey:'kristof'        //overrule that all SSH keys will be used from VDC, only use kristof now

!!vdc.vm_define vdc:'myvdc' name:'containerhost'
    mem:'8'                  //means 8 GB
    networks:'internalnet1'  //will not be attached to a network oob (MAYBE in first release we only support 1 network in VDC)
    country:'belgium'        //will chose a random node in belgium
    ipv4_pub:1
    docker:1                //means we know this VM is meant to run docker containers
    
!!vdc.vdisk_define vdc:'myvdc' vm:'vm1' name:'vm1_disk_root' 
    size:'40 GB' //supported tb,gb,mb is case insensitive, spaces ignored, default is GB
    vm_path:'/root/data' //location in VM

!!vdc.vdisk_define vdc:'myvdc' vm:'vm1' name:'vm1_disk_code' 
    size:'10 GB' //supported tb,gb,mb is case insensitive, spaces ignored, default is GB
    vm_path:'/code' //location in VM

!!vdc.vnet_define vdc:'myvdc' name:'internalnet1' 

!!vdc.vnet_define vdc:'myvdc' name:'oob1' description:'used for our out of bandnetwork, going to web' 
    range:'TBD' //is it ipv4? how to define best?, if not defined is auto generated and unique for VDC


```

Networks are auto deployed as its needed on 3nodes to comply to network connections as made.