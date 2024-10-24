# This is our business model planner

## FUNDING

!!bizmodel.sheet_wiki includefilter:'funding'

## REVENUE vs COGS

!!bizmodel.sheet_wiki includefilter:rev

#### Revenue Lines

!!bizmodel.sheet_wiki title:'Revenue Total' includefilter:'revtotal'

#### COGS Lines

!!bizmodel.sheet_wiki title:'COGS' includefilter:'cogstotal'

## HR
!!bizmodel.sheet_wiki title:'HR Teams' includefilter:'hrnr'

!!bizmodel.sheet_wiki title:'HR Costs' includefilter:'hrcost'

## Operational Costs

!!bizmodel.sheet_wiki title:'COSTS' includefilter:'ocost'


## P&L Overview

<!-- period is in months, 3 means every quarter -->

!!bizmodel.sheet_wiki title:'P&L Overview' includefilter:'pl' 


!!bizmodel.graph_bar_row rowname:revenue_total unit:million title:'A Title' title_sub:'Sub'

Unit is in Million USD.

!!bizmodel.graph_bar_row rowname:revenue_total unit:million

!!bizmodel.graph_line_row rowname:revenue_total unit:million

!!bizmodel.graph_pie_row rowname:revenue_total unit:million size:'80%'


## Some Details

> show how we can do per month

!!bizmodel.sheet_wiki includefilter:'pl' period_months:1



