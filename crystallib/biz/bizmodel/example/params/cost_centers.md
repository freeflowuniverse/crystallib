# HR Params

## Engineering

Costs can be grouped in cost centers which can then be used to futher process e.g. transcactions between companies.

```js

!!costcenter.define
    name:'tfdmcc'
    descr:'TFDMCC executes on near source agreement for TFTech' 
    min_month:'10000USD'    
    max_month:'100000USD'
    end_date:'1/1/2026'   //when does agreement stop
 
!!costcenter.define
    name:'cs_tftech'
    descr:'Nearsource agreement for TFTech towards Codescalers' 
    min_month:'10000USD'    
    max_month:'100000USD'
    end_date:'1/1/2026'

!!costcenter.define
    name:'cs_tfcloud'
    descr:'Nearsource agreement for TFCloud towards Codescalers' 
    min_month:'10000USD'    
    max_month:'100000USD'
    end_date:'1/1/2026'


```
