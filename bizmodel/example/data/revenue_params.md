# HR Params

## Revenue Items (non recurring)

possible parameters

- name, e.g. for a specific project
- descr, description of the revenue line item
- revenue_item, revenue for 1 item '1000USD', can change over time e.g. 0:1000USD,10:1200USD
- revenue_nr: how many items are sold of the revenue specification e.g. 1:100,60:200 means growing from 100 to 200 over 6Y
- revenue_time, revenue per specific times, e.g. month 10, OEM deal of 1000, month 20 another one would be '10:1000,20:1000'
- cogs_delay_month: how many months delay on cost of goods, default is 0 months
- cogs_perc: what is percentage of the cogs (can change over time) e.g. 0:5%,12:10%

if currency not specified then is always in USD

```js
// !!revenue.define 
//     descr:'OEM Deals'  
//     revenue_time:'10:1000000USD,20:1200000'
//     cogs_perc: '1:5%,20:10%'  

// !!revenue.define 
//     descr:'License Deals'  
//     revenue_growth:'10:1000,20:1100'
//     cogs_perc: '10%'  
//     rev_delay_month: 1

// !!revenue.define 
//     descr:'3NODE License Sales 1 Time'  
//     //means revenue is 100 month 1, 200 month 60
//     revenue_item:'1:100,60:200'
//     revenue_nr:'10:1000,24:2000,60:40000'
//     cogs_perc: '10%'
//     rev_delay_month: 1
```

## Revenue Items Recurring

possible parameters

- name, e.g. for a specific project
- descr, description of the revenue line item
- revenue_setup, revenue for 1 item '1000usd'
- revenue_monthly, revenue per month for 1 item
- revenue_monthly_delay, how many months before monthly revenue starts
- cogs_setup, cost of good for 1 item at setup
- cogs_setup_delay, in int, is expressed in months
- cogs_setup_perc: what is percentage of the cogs (can change over time) for setup e.g. 0:50%
- cogs_monthly, cost of goods for the monthly per 1 item 
- cogs_monthly_delay, in int, is for months
- cogs_monthly_perc: what is percentage of the cogs (can change over time) for monthly e.g. 0:5%,12:10%
- nr_sold: how many do we sell per month (is in growth format e.g. 10:100,20:200)
- nr_months: how many months is recurring

if currency not specified then is always in USD

```js

!!revenue.recurring_define 
    name: '3node_lic'
    descr:'3NODE License Sales Recurring Basic'  
    // revenue_setup:'1:100,60:50'
    revenue_setup:'5'
    revenue_monthly_delay:'0'
    revenue_monthly:'1:1,60:1'
    // cogs_setup:'1:0'
    cogs_setup_perc:'50%'
    cogs_setup_delay:'0'
    cogs_monthly_perc:'50%'
    cogs_monthly_delay:'0'
    nr_sold:2
    // nr_sold:'10:1000,24:2000,60:40000'
    //60 is the default
    nr_months:60 
```

