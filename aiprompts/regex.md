
# Regex Library

#### Differences with PCRE:

> regex is not PCRE compatible.

- The basic element is the token not the sequence of symbols, and the mostsimple token, is a single character.
 | the OR operator acts on tokens, for example abc|ebc is notabc OR ebc. Instead it is evaluated like ab, followed by c OR e, followed by bc, because the token is the base element, not the sequence of symbols.
- Two char classes with an OR in the middle is a syntax error.
- The match operation stops at the end of the string. It does NOT stopat new line characters.
- The tokens are the atomic units, used by this regex engine. They can be one of the following:
  - Simple char, This token is a simple single character like a or b etc.
- Match positional delimiters
  - ^ Matches the start of the string.
  - $ Matches the end of the string.

#### Char class (cc)

- The character classes match all the chars specified inside. Use square brackets [ ] to enclose them.
- The sequence of the chars in the character class, is evaluated with an OR op.
- For example, the cc [abc], matches any character, that is a or b or c, but it doesn't match C or z.
- Inside a cc, it is possible to specify a "range" of characters, for example [ad-h] is equivalent to writing [adefgh].
- A cc can have different ranges at the same time, for example [a-zA-Z0-9] matches all the latin lowercase, uppercase and numeric characters.
- It is possible to negate the meaning of a cc, using the caret char at the start of the cc like this: [^abc] . That matches every char that is NOT a or b or c.
- A cc can contain meta-chars like: [a-z\d], that match all the lowercase latin chars a-z and all the digits \d.
- It is possible to mix all the properties of the char class together.
- Note > In order to match the - (minus) char, it must be preceded by > a backslash in the cc, for example [\-_\d\a] will match: > - - minus, > - _ underscore, > - \d numeric chars, > - \a lower case chars.

#### Meta-chars

- A meta-char is specified by a backslash, before a character. For example \w is the meta-char w.
- A meta-char can match different types of characters.
- \w matches a word char [a-zA-Z0-9_]
- \W matches a non word char
- \d matches a digit [0-9]
- \D matches a non digit
- \s matches a space char, one of [' ','\t','\n','\r','\v','\f']
- \S matches a non space char
- \a matches only a lowercase char [a-z]
- \A matches only an uppercase char [A-Z]
- \x41 match a byte of value 0x41, A in ascii code
- \X414C match two consecutive bytes of value 0x414c, AL in ascii code

#### Quantifiers

Each token can have a quantifier, that specifies how many times the character must be matched.

Short quantifiers

- ? matches 0 or 1 time, a?b matches both ab or b
- + matches at least 1 time, for example, a+ matches both aaa or a
- * matches 0 or more times, for example, a*b matches aaab, ab or b

Long quantifiers

- {x} matches exactly x times, a{2} matches aa, but not aaa or a
- {min,} matches at least min times, a{2,} matches aaa or aa, not a
- {,max} matches at least 0 times and at maximum max times,for example, a{,2} matches a and aa, but doesn't match aaa- {min,max} matches from min times, to max times, for examplea{2,3} matches aa and aaa, but doesn't match a or aaaa
- A long quantifier, may have a greedy off flag, that is the ? character after the brackets. {2,4}? means to match the minimum number of possible tokens, in this case 2.


#### dot char

The dot is a particular meta-char, that matches "any char".

input:

'''abccc ddeef'''

The following table shows the query strings and the result of parsing source string.

| query string | result |
|--------------|---------|
| `.*c`        | `abc`   |
| `.*dd`       | `abcc dd` |
| `ab.*e`      | `abccc dde`|
| `ab.{3} .*e` | `abccc dde`|

- The dot matches any character, until the next token match is satisfied.
- Important Note: Consecutive dots, for example ..., are not allowed. > This will cause a syntax error. Use a quantifier instead.

OR token
The token |, means a logic OR operation between two consecutive tokens, i.e. a|b matches a character that is a or b.

The OR token can work in a "chained way": a|(b)|cd means test first a, if the char is not a, then test the group (b), and if the group doesn't match too, finally test the token c.

Note > Unlike in PCRE, the OR operation works at token level! > It doesn't work at concatenation level!

Note > Two char classes with an OR in the middle is a syntax error.

That also means, that a query string like abc|bde is not equal to (abc)|(bde), but instead to ab(c|b)de. The OR operation works only for c|b, not at char concatenation level.

#### Groups

Groups are a method to create complex patterns with repetitions of blocks of tokens.

The groups are delimited by round brackets `( )`.

Groups can be nested. Like all other tokens, groups can have a quantifier too.

- `c(pa)+z` match `cpapaz` or `cpaz` or `cpapapaz`.
- `(c(pa)+z ?)+` matches `cpaz cpapaz cpapapaz` or `cpapaz`

Let's analyze this last case, first we have the group `#0`, that is the most outer round brackets `(...)+`. This group has a quantifier `+`, that says to match its content at least one time.
Then we have a simple char token `c`, and a second group `#1`: `(pa)+`. This group also tries to match the sequence `pa`, at least one time, as specified by the `+` quantifier.
Then, we have another simple token `z` and another simple token `?`, i.e. the space char (ascii code 32) followed by the `?` quantifier, which means that the preceding space should be matched 0 or 1 time.

This explains why the `(c(pa)+z ?)+` query string, can match `cpaz cpapaz cpapapaz`.

In this implementation the groups are "capture groups". This means that the last temporal result for each group, can be retrieved from the `RE` struct.

The "capture groups" are stored as indexes in the field `groups`, that is an `[]int` inside the `RE` struct.

example

```v
import regex

text := 'cpaz cpapaz cpapapaz'
query := r'(c(pa)+z ?)+'
mut re := regex.regex_opt(query) or { panic(err) }
println(re.get_query())
// #0(c#1(pa)+z ?)+
// #0 and #1 are the ids of the groups, are shown if re.debug is 1 or 2
start, end := re.match_string(text)
// [start=0, end=20]  match => [cpaz cpapaz cpapapaz]
mut gi := 0
for gi < re.groups.len {
    if re.groups[gi] >= 0 {
        println('${gi / 2} :[${text[re.groups[gi]..re.groups[gi + 1]]}]')
    }
    gi += 2
}
// groups captured
// 0 :[cpapapaz]
// 1 :[pa]
```

Note > To show the group id number in the result of the get_query() > the flag debug of the RE object must be 1 or 2

In order to simplify the use of the captured groups, it is possible to use the utility function: get_group_list.

This function returns a list of groups using this support struct:

```v
pub struct Re_group {
pub:
    start int = -1
    end   int = -1
}
```


Groups example:

This simple function converts an HTML RGB value with 3 or 6 hex digits to an u32 value, this function is not optimized and it is only for didatical purpose. Example: #A0B0CC #A9F

```v
import regex

fn convert_html_rgb(in_col string) u32 {
    mut n_digit := if in_col.len == 4 { 1 } else { 2 }
    mut col_mul := if in_col.len == 4 { 4 } else { 0 }
    // this is the regex query, it uses the V string interpolation to customize the regex query
    // Note: If you want to use escaped code you must use the r"" (raw) strings,
    // *** please remember that the V interpoaltion doesn't work on raw strings. ***
    query :='#([a-fA-F0-9]{${n_digit}})([a-fA-F0-9]{${n_digit}})([a-fA-F0-9]{${n_digit}})'
    mut re := regex.regex_opt(query) or { panic(err) }
    start, end := re.match_string(in_col)
    println('start: ${start}, end: ${end}')
    mut res := u32(0)
    if start >= 0 {
        group_list := re.get_group_list() // this is the utility function
        r := ('0x' + in_col[group_list[0].start..group_list[0].end]).int() << col_mul
        g := ('0x' + in_col[group_list[1].start..group_list[1].end]).int() << col_mul
        b := ('0x' + in_col[group_list[2].start..group_list[2].end]).int() << col_mul
        println('r: ${r} g: ${g} b: ${b}')
        res = u32(r) << 16 | u32(g) << 8 | u32(b)
    }
    return res
}
```

Other utility functions are get_group_by_id and get_group_bounds_by_id that get directly the string of a group using its id:

```v
txt := 'my used string....'
for g_index := 0; g_index < re.group_count; g_index++ {
    println('#${g_index} [${re.get_group_by_id(txt, g_index)}] \
    }] bounds: ${re.get_group_bounds_by_id(g_index)}')
}
```

More helper functions are listed in the Groups query functions section.

Groups Continuous saving
In particular situations, it is useful to have a continuous group saving. This is possible by initializing the group_csave field in the RE struct.

This feature allows you to collect data in a continuous/streaming way.

In the example, we can pass a text, followed by an integer list, that we wish to collect. To achieve this task, we can use the continuous group saving, by enabling the right flag: re.group_csave_flag = true.

The .group_csave array will be filled then, following this logic:

re.group_csave[0] - number of total saved records re.group_csave[1+n*3] - id of the saved group re.group_csave[2+n*3] - start index in the source string of the saved group re.group_csave[3+n*3] - end index in the source string of the saved group

The regex will save groups, until it finishes, or finds that the array has no more space. If the space ends, no error is raised, and further records will not be saved.

```v
import regex

txt := 'http://www.ciao.mondo/hello/pippo12_/pera.html'
query := r'(?P<format>https?)|(?P<format>ftps?)://(?P<token>[\w_]+.)+'

mut re := regex.regex_opt(query) or { panic(err) }
// println(re.get_code())   // uncomment to see the print of the regex execution code
re.debug = 2 // enable maximum log
println('String: ${txt}')
println('Query : ${re.get_query()}')
re.debug = 0 // disable log
re.group_csave_flag = true
start, end := re.match_string(txt)
if start >= 0 {
    println('Match (${start}, ${end}) => [${txt[start..end]}]')
} else {
    println('No Match')
}

if re.group_csave_flag == true && start >= 0 && re.group_csave.len > 0 {
    println('cg: ${re.group_csave}')
    mut cs_i := 1
    for cs_i < re.group_csave[0] * 3 {
        g_id := re.group_csave[cs_i]
        st := re.group_csave[cs_i + 1]
        en := re.group_csave[cs_i + 2]
        println('cg[${g_id}] ${st} ${en}:[${txt[st..en]}]')
        cs_i += 3
    }
}
```

The output will be:

```v
String: http://www.ciao.mondo/hello/pippo12_/pera.html
Query : #0(?P<format>https?)|{8,14}#0(?P<format>ftps?)://#1(?P<token>[\w_]+.)+
Match (0, 46) => [http://www.ciao.mondo/hello/pippo12_/pera.html]
cg: [8, 0, 0, 4, 1, 7, 11, 1, 11, 16, 1, 16, 22, 1, 22, 28, 1, 28, 37, 1, 37, 42, 1, 42, 46]
cg[0] 0 4:[http]
cg[1] 7 11:[www.]
cg[1] 11 16:[ciao.]
cg[1] 16 22:[mondo/]
cg[1] 22 28:[hello/]
cg[1] 28 37:[pippo12_/]
cg[1] 37 42:[pera.]
cg[1] 42 46:[html]
```v

#### Named capturing groups

This regex module supports partially the question mark ? PCRE syntax for groups.

- `(?:abcd)` non capturing group: the content of the group will not be saved.
- `(?P<mygroup>abcdef)` named group: the group content is saved and labeled as mygroup.

The label of the groups is saved in the `group_map` of the `RE` struct, that is a map from `string` to `int`, where the value is the index in `group_csave` list of indexes.

Here is an example for how to use them:

```v
import regex


txt := 'http://www.ciao.mondo/hello/pippo12_/pera.html'
query := r'(?P<format>https?)|(?P<format>ftps?)://(?P<token>[\w_]+.)+'

mut re := regex.regex_opt(query) or { panic(err) }
// println(re.get_code())   // uncomment to see the print of the regex execution code
re.debug = 2 // enable maximum log
println('String: ${txt}')
println('Query : ${re.get_query()}')
re.debug = 0 // disable log
start, end := re.match_string(txt)
if start >= 0 {
    println('Match (${start}, ${end}) => [${txt[start..end]}]')
} else {
    println('No Match')
}

for name in re.group_map.keys() {
    println('group:${name} \t=> [${re.get_group_by_name(txt, name)}] \
    }] bounds: ${re.get_group_bounds_by_name(name)}')
}

```

Output:

```
String: http://www.ciao.mondo/hello/pippo12_/pera.html
Query : #0(?P<format>https?)|{8,14}#0(?P<format>ftps?)://#1(?P<token>[\w_]+.)+
Match (0, 46) => [http://www.ciao.mondo/hello/pippo12_/pera.html]
group:format 	=> [http] bounds: (0, 4)
group:token 	=> [html] bounds: (42, 46)
```

In order to simplify the use of the named groups, it is possible to use a name map in the re struct, using the function `re.get_group_by_name`.

Here is a more complex example of using them:

```v
import regex

// This function demonstrate the use of the named groups
fn convert_html_rgb_n(in_col string) u32 {
    mut n_digit := if in_col.len == 4 { 1 } else { 2 }
    mut col_mul := if in_col.len == 4 { 4 } else { 0 }
    query := r'#(?P<red>[a-fA-F0-9]{${n_digit}})(?P<green>[a-fA-F0-9]{${n_digit}})(?P<blue>[a-fA-F0-9]{${n_digit}})'
    mut re := regex.regex_opt(query) or { panic(err) }
    start, end := re.match_string(in_col)
    println('start: ${start}, end: ${end}')
    mut res := u32(0)
    if start >= 0 {
        red_s, red_e := re.get_group_bounds_by_name('red')
        r := ('0x' + in_col[red_s..red_e]).int() << col_mul
        green_s, green_e := re.get_group_bounds_by_name('green')
        g := ('0x' + in_col[green_s..green_e]).int() << col_mul
        blue_s, blue_e := re.get_group_bounds_by_name('blue')
        b := ('0x' + in_col[blue_s..blue_e]).int() << col_mul
        println('r: ${r} g: ${g} b: ${b}')
        res = u32(r) << 16 | u32(g) << 8 | u32(b)
    }
    return res
}
```

Other utilities are `get_group_by_name` and `get_group_bounds_by_name`, that return the string of a group using its name:

```v
txt := 'my used string....'
for name in re.group_map.keys() {
    println('group:${name} \t=> [${re.get_group_by_name(txt, name)}] \
    }] bounds: ${re.get_group_bounds_by_name(name)}')
}
```

#### Groups query functions

These functions are helpers to query the captured groups

```v
// get_group_bounds_by_name get a group boundaries by its name
pub fn (re RE) get_group_bounds_by_name(group_name string) (int, int)

// get_group_by_name get a group string by its name
pub fn (re RE) get_group_by_name(group_name string) string

// get_group_by_id get a group boundaries by its id
pub fn (re RE) get_group_bounds_by_id(group_id int) (int, int)

// get_group_by_id get a group string by its id
pub fn (re RE) get_group_by_id(in_txt string, group_id int) string

struct Re_group {
pub:
    start int = -1
    end   int = -1
}

// get_group_list return a list of Re_group for the found groups
pub fn (re RE) get_group_list() []Re_group

// get_group_list return a list of Re_group for the found groups
pub fn (re RE) get_group_list() []Re_group
Flags
It is possible to set some flags in the regex parser, that change the behavior of the parser itself.

```

#### init the regex struct with flags (optional)

```v
mut re := regex.new()
re.flag = regex.f_bin
// f_bin: parse a string as bytes, utf-8 management disabled.
// f_efm: exit on the first char matches in the query, used by thefind function.
//f_ms: matches only if the index of the start match is 0,same as ^ at the start of the query string.
// f_me: matches only if the end index of the match is the last charof the input string, same as $ end of query string.
// f_nl: stop the matching if found a new line char \n or \r
```


## Simplified initializer

```v
// regex create a regex object from the query string and compile it
pub fn regex_opt(in_query string) ?RE

// new create a RE of small size, usually sufficient for ordinary use
pub fn new() RE

//After an initializer is used, the regex expression must be compiled with:

// compile_opt compile RE pattern string,  returning an error if the compilation fails
pub fn (mut re RE) compile_opt(pattern string) !
```

## Matching Functions

```v

// match_string try to match the input string, return start and end index if found else start is -1
pub fn (mut re RE) match_string(in_txt string) (int, int)
```

## Find functions

```v
// find try to find the first match in the input string
// return start and end index if found else start is -1
pub fn (mut re RE) find(in_txt string) (int, int)

// find_all find all the "non overlapping" occurrences of the matching pattern
// return a list of start end indexes like: [3,4,6,8]
// the matches are [3,4] and [6,8]
pub fn (mut re RE) find_all(in_txt string) []int

// find_all_str find all the "non overlapping" occurrences of the match pattern
// return a list of strings
// the result is like ['first match','secon match']
pub fn (mut re RE) find_all_str(in_txt string) []string
```

## Replace functions

```v
// replace return a string where the matches are replaced with the repl_str string,
// this function supports groups in the replace string
pub fn (mut re RE) replace(in_txt string, repl string) string

//replace string can include groups references:


txt := 'Today it is a good day.'
query := r'(a\w)[ ,.]'
mut re := regex.regex_opt(query)?
res := re.replace(txt, r'__[\0]__')

```
in above example we used the group 0 in the replace string: \0, the result will be:

Today it is a good day. => Tod__[ay]__it is a good d__[ay]__

Note > In the replace strings can be used only groups from 0 to 9.

If the usage of groups in the replace process, is not needed, it is possible to use a quick function:

```v
// replace_simple return a string where the matches are replaced with the replace string
pub fn (mut re RE) replace_simple(in_txt string, repl string) string

//If it is needed to replace N instances of the found strings it is possible to use:


// replace_n return a string where the first `count` matches are replaced with the repl_str string
// `count` indicate the number of max replacements that will be done.
// if count is > 0 the replace began from the start of the string toward the end
// if count is < 0 the replace began from the end of the string toward the start
// if count is 0 do nothing
pub fn (mut re RE) replace_n(in_txt string, repl_str string, count int) string

//For complex find and replace operations, you can use replace_by_fn . The replace_by_fn, uses a custom replace callback function, thus allowing customizations. The custom callback function is called for every non overlapped find.
// The custom callback function must be of the type:


// type of function used for custom replace
// in_txt  source text
// start   index of the start of the match in in_txt
// end     index of the end   of the match in in_txt
// --- the match is in in_txt[start..end] ---
fn (re RE, in_txt string, start int, end int) string
The following example will clarify its usage:

```
customized replace function example

```v

import regex
//
// it will be called on each non overlapped find

fn my_repl(re regex.RE, in_txt string, start int, end int) string {
    g0 := re.get_group_by_id(in_txt, 0)
    g1 := re.get_group_by_id(in_txt, 1)
    g2 := re.get_group_by_id(in_txt, 2)
    return'*${g0}*${g1}*${g2}*'
}

fn main() {
    txt := 'today [John] is gone to his house with (Jack) and [Marie].'
    query := r'(.)(\A\w+)(.)'

    mut re := regex.regex_opt(query) or { panic(err) }

    result := re.replace_by_fn(txt, my_repl)
    println(result)
}
```

Output:

```txt
today *[*John*]* is gone to his house with *(*Jack*)* and *[*Marie*]*.
```
