## filtering

Is a very powerful mechanism how to find information from rootobjects

each rootobject has 3 selectors

- selectors:
  - namefilter, use filter statements on name of the rootobject
  - includefilter, use filter statements on tags of the rootobject
  - excludefilter, use filter statements on tags

See [tags](tags.md) for more info on how those are constructed.

### filter statements

- Example
    - e.g. 'location:belgium_*,urgent'
        - would match all words starting with belgium_ for tag location
        - also urgent would be needed

**examples**:

```go
//example of tags
tags=```arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok' ```
```


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