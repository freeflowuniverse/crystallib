
# Revenue Overview

@for name1,product in sim.products

@if product.has_revenue

## ${product.title}

${product.description}

#### parameters for the product

@if product.has_oneoffs

Product ${name1} has revenue events (one offs)

!!!spreadsheet.sheet_wiki 
    namefilter:'${name1}_revenue,${name1}_cogs,${name1}_cogs_perc,${name1}_maintenance_month_perc' sheetname:'bizmodel_tf9

- COGS = Cost of Goods Sold (is our cost to deliver the product/service)
- maintenance is fee we charge to the customer per month in relation to the revenue we charged e.g. 1% of a product which was sold for 1m EUR means we charge 1% of 1 m EUR per month.

@end //one offs

@if product.has_items

Product sold and its revenue/cost of goods

!!!spreadsheet.sheet_wiki 
    namefilter:'${name1}_nr_sold,${name1}_revenue_setup,${name1}_revenue_monthly,${name1}_cogs_setup,${name1}_cogs_setup_perc,${name1}_cogs_monthly,${name1}_cogs_monthly_perc'
    sheetname:'bizmodel_tf9

- nr sold, is the nr sold per month of ${name1}
- revenue setup is setup per item for ${name1}, this is the money we receive. Similar there is a revenue monthly.
- cogs = Cost of Goods Sold (is our cost to deliver the product)
    - can we as a setup per item, or per month per item

@if product.nr_months_recurring>1

This product ${name1} is recurring, means customer pays per month ongoing, the period customer is paying for in months is: **${product.nr_months_recurring}**

@end //recurring

@end

#### the revenue/cogs calculated


!!!spreadsheet.sheet_wiki 
    namefilter:'${name1}_nr_sold_recurring'
    sheetname:'bizmodel_tf9

This results in following revenues and cogs:

!!!spreadsheet.sheet_wiki 
    namefilter:'${name1}_revenue_setup_total,${name1}_revenue_monthly_total,${name1}_cogs_setup_total,${name1}_cogs_monthly_total,${name1}_cogs_setup_from_perc,${name1}_cogs_monthly_from_perc,${name1}_maintenance_month,
    ${name1}_revenue_monthly_recurring,${name1}_cogs_monthly_recurring'
    sheetname:'bizmodel_tf9

resulting revenues:
!!!spreadsheet.sheet_wiki 
    namefilter:'${name1}_revenue_total,${name1}_cogs_total'
    sheetname:'bizmodel_tf9


!!!spreadsheet.graph_line_row rowname:'${name1}_cogs_total' unit:million sheetname:'bizmodel_tf9'

!!!spreadsheet.graph_line_row rowname:'${name1}_revenue_total' unit:million sheetname:'bizmodel_tf9'


@end //product has_revenue

@end //loop