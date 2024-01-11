
## split as swiss army knife

```golang
assert 'A B C'.split(' ') == ['A','B','C']
assert 'DEF'.split('') == ['D','E','F']
assert ' my last\tname and first name   '.fields()
split_into_lines()
//splits the string based on the passed delim substring. It returns the first Nth parts. Last one is all remaining
split_nth(delim string, nth int) []string  

```

## string functions are quite important 

before and after...

```golang
assert '23:34:45.first.234'.all_after_last('.') == '234'
assert 'abcd'.all_after('z') == 'abcd'
assert '23:34:45.234'.all_after_first(':') == '34:45.234'
assert '23:34:45.234'.all_before('.') == '23:34:45'
assert 'abcd'.all_before('.') == 'abcd'
assert '23:34:45.234'.all_before_last(':') == '23:34'
```

contains / count / ends_withs, starts_with

```golang
assert 'my name'.contains(" ")
assert 'my name'.contains_any_substr([" ","a"])
assert 'my name'.contains_any_substr(["b","a"])
assert 'my name'.contains(" ")==1
assert 'my name'.ends_with("name")
assert 'my name'.starts_with("my")

```

fields super powerful to over over list and get right info out

```golang
//split over " " and tab
assert '  my last\tname and first name   '.fields()==['my', 'last', 'name', 'and', 'first', 'name'] 
//ignores starting space or tabs is ignored, so is end of string
assert '  \tmy last\tname and first name   \t   \n'.fields()==['my', 'last', 'name', 'and', 'first', 'name'] 

```

see [here](https://modules.vlang.io/index.html#string)

### other usefull on string

```golang
replace()
trim_space()
assert 'WorldHello V'.trim_string_left('World') == 'Hello V'
trim_string_right()
is_blank()
is_capital()
is_upper()
is_lower()
normalize_tabs(tab_len int) string  //replace tabs to strings
'hello'.limit(2) => 'he'
```


### glob match

match_glob matches the string, with a Unix shell-style wildcard pattern.

Note: wildcard patterns are NOT regular expressions. 

The special characters used in shell-style wildcards are: 
- `*` - matches everything 
- `?` - matches any single character 
- `[seq]` - matches any of the characters in the sequence 
- `[^seq]` - matches any character that is NOT in the sequence 
- Any other character in pattern, is matched 1:1 to the corresponding character in name, including / and . 
- You can wrap the meta-characters in brackets too, i.e. [?] matches ? in the string, and [*] matches * in the string.

```golang
assert 'ABCD'.match_glob('AB*')
assert 'ABCD'.match_glob('*D')
assert 'ABCD'.match_glob('*B*')
assert !'ABCD'.match_glob('AB')
```

### string to int...

```golang
parse_int
```
