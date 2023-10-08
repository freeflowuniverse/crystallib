# Tables



### how to represent a graph bar

```js

!!bizmodel.graph_bar_row rowname:revenue_total unit:million title:'A Title' title_sub:'Sub'

```
### params

- title: title of the tables widget
- title_sub: ...
- name, name of the widget
- unit: million (to show unit as )
- selectors:
  - rowname: only include the exact names as secified for the row (if only one row)
  - [namefilter](namefilter.md)
  - includefilter, which rows to include look at overview of rows to see which ones there are
  - excludefilter, which rows not to include
  - period_months (default 12)



				rowname: rowname
				period_type: period_type_e
				unit: unit_e
				title_sub: title_sub
				title: title
				size: size


## unit

if used the value as in the row in the sheet will be divided

- normal (default)
- thousand
- million
- billion

## aggregate over a period

- year (default)
- month
- quarter

