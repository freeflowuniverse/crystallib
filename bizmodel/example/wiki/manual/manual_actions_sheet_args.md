
### available arguments

```go
Arguments{
	rowname        string  // only include the exact names as secified for the row (if only one row
	include       []string // to use with params filter e.g. ['location:belgium_*'] //would match all words starting with belgium
	exclude       []string  
	period_type   PeriodType //year, month, quarter
    aggregate     0 or 1 //if more than 1 row matches should we aggregate or not
    aggregatetype RowAggregateType = .sum //important if used with include/exclude, because then we group
    unit          UnitType 
    title         string //only used for charts now
    title_sub     string //only used for charts now = subtitle
    size          string //only relevant for pie chart (default 100%)
    }

RowAggregateType{
	sum //is the default
	avg
	max
	min
}

UnitType{
  normal //is without a unit
  thousand
  million
  billion
}


PeriodType{
  year //is the default
  month
  quarter
}

```

for includes and excludes see [sheet includes and excludes](manual_include_excludes.md)

#### define period

> TODO: not working yet
> 
```js
!!bizmodel.graph_bar_row rowname:revenue_total period:3
```

period is in months, 3 means every quarter, 12 is the default which is per year and the default



