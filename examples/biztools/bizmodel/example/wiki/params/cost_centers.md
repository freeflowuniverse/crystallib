# HR Params

## Engineering

Costs can be grouped in cost centers which can then be used to futher process e.g. transcactions between companies.

```js

!!bizmodel.costcenter_define bizname:'test'
    name:'tfdmcc'
    descr:'TFDMCC executes on near source agreement for TFTech'
    min_month:'10000USD'
    max_month:'100000USD'
    end_date:'1/1/2026'   //when does agreement stop

!!bizmodel.costcenter_define bizname:'test'
    name:'cs_tftech'
    descr:'Nearsource agreement for TFTech towards Codescalers'
    min_month:'10000USD'
    max_month:'100000USD'
    end_date:'1/1/2026'

!!bizmodel.costcenter_define bizname:'test'
    name:'cs_tfcloud'
    descr:'Nearsource agreement for TFCloud towards Codescalers'
    min_month:'10000USD'
    max_month:'100000USD'
    end_date:'1/1/2026'


```
