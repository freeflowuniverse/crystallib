# Selectors

how can we use selectors to find proper nodes, can be on 3e party network

```javascript

!!vdc.nodeselector_define name:myselector
    farm:'1,2,3,4,5'               //a range of farms
    country:'be'                   //see V we have populated normalized list of countries
    mem_min:10                     //default in GB, but can specify MB
    mem_max:100
    vcpu_min:16
    vcpu_max:32
    ssd_min:1000
    ssd_max:20000
    price_month_max:100              //max price per month, USD is default, can specify other currency (see currency module V)
    certified:true
    gpu_tflops_min:11               //as used on https://cloud.vast.ai/
    gpu_tflops_max:111
    gpu_filter:'A40'                 //needs to be in description of GPU, can be a list
    gpu_mem_min:20
    gpu_mem_max:60
    cpu_filter:'amd'                 //filters can be a list, will allways be made lowercase
    cpu_nr_min:4                     //nr of minimal CPU's
    cpu_passmark_min:30000
    cpu_passmark_max:50000
    uptime:99                        //in percent
    bandwidth_min:'1MBS'             //MB means mbyte per sec
    reputation_min:4                 //not used now
    networks:'tfgrid3'               //tfgrid3, avast, ... (default its all open, but we give preference to tfgrid if possible)
    nodes:'22,33,44,55'              //we can specify a list of 3nodes, which the algo will chose out from


!!vdc.nodeselector_define name:myselector2
    country:'de'                   //now we go for another country
    price_month_max:100 
    cpu_nr_min:2                     //nr of minimal CPU's

```



Selectors can be used to have detailed selection criteria of nodes.

Like this its super easy to get node's in locations we want which live up to certain requirements.