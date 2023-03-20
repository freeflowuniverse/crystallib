# Sheet 

The idea is to have a module which allows us to make software representation of a spreadsheet.

The spreadsheet has a currency linked to it and also multi currency behavior, it also has powerful extra/intrapolation possibilities.

A sheet has following format

If we have 60 months representation (5 year), we have 60 columns

- rows, each row represent something e.g. salary for a person per month over 5 years
- the rows can be grouped per tags
- each row has 60 cols = cells, each cell has a value
- each row has a name

A sheet can also be represented per year or per quarter, if per year then there would be 5 columns only.

There is also functionality to export a sheet to wiki (markdown) or html representation.

## offline

if you need to work offline e.g. for development do

```bash
export OFFLINE=1
```