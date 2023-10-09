# This is our business model planner

## P&L Overview


<!-- period is in months, 3 means every quarter -->


!!bizmodel.graph_bar_row rowname:revenue_total unit:million title:'A Title' title_sub:'Sub'

Unit is in Million USD.

!!bizmodel.graph_bar_row rowname:revenue_total unit:million

!!bizmodel.graph_line_row rowname:revenue_total unit:million

!!bizmodel.graph_pie_row rowname:revenue_total unit:million size:'80%'

## FUNDING

!!bizmodel.sheet_wiki includefilter:'funding'

!!bizmodel.sheet_wiki title:'REVENUE' includefilter:rev

!!bizmodel.sheet_wiki title:'Revenue Total' includefilter:'revtotal'

!!bizmodel.sheet_wiki title:'REVENUE' includefilter:'revtotal2'

!!bizmodel.sheet_wiki title:'COGS' includefilter:'cogs'

!!bizmodel.sheet_wiki title:'Margin' includefilter:'margin'

!!bizmodel.sheet_wiki title:'HR Teams' includefilter:'hrnr'

!!bizmodel.sheet_wiki title:'HR Costs' includefilter:'hrcost'

!!bizmodel.sheet_wiki title:'COSTS' includefilter:'ocost'

!!bizmodel.sheet_wiki title:'HR Costs' includefilter:'hrcost'

!!bizmodel.sheet_wiki title:'P&L Overview' includefilter:'pl' 

!!bizmodel.sheet_wiki title:'P&L Overview' includefilter:'pl' 

## Some Details

> show how we can do per month

!!bizmodel.sheet_wiki includefilter:'pl' period_months:1



