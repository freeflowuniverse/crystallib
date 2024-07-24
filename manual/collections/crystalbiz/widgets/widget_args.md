# widget args

## params

- title: title of the tables widget
- title_sub: ...
- unit: the value can be divided by (normal, thousand, million, billion), normal means no divide
- period_type:  (year, quarter, month): period to show
- rowname_show:  (default true) show the name of the row, only relevant for table view
- size: size of widget (only relevant for graphs): 25-100
- aggregatetype: (sum.max,min), relevant if more than one row matches
- selectors:
  - namefilter, use filter statements on names
  - includefilter, use filter statements on tags of rows to include
  - excludefilter, use filter statements on tags of rows to exclude


### filter statements

- Each row has a set of tags linked to it, these tags can be named or not.
    - e.g. ```location:belgium``` would be named tag
    - e.g. ```urgent``` is not named
- Example
    - e.g. 'location:belgium_*,urgent'
        - would match all words starting with belgium_ for tag location
        - also urgent would be needed

**example**:

tags=```arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok' ```

- ```description:*see*``` will match the description at end
- ```description:*seee*``` will not match anything
- ```priority:incredible``` will match
- ```color:red``` will match
- ```color:red+priority:incredible``` will match 
- ```color:green+priority:incredible``` will not match 
- ```arg2``` will match 
- ```arg``` will not match 
- ```arg*``` will match 
- ```arg1+arg2``` will match 
- ```arg1+arg3``` will not match 

In case of include & exclude filters its for all tags, and if exclude true and include true, then will not match.

### unit

if used the value as in the row in the sheet will be divided

- normal (default)
- thousand
- million
- billion

### aggregate over a period

- year (default)
- month
- quarter
