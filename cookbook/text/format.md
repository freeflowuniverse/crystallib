## String interpolation

Basic interpolation syntax is pretty simple - use ${ before a variable name and } after. 

The variable will be converted to a string and embedded into the literal:

```golang
name := 'Bob'
println('Hello, ${name}!') // Hello, Bob!
```

It also works with fields: 'age = ${user.age}'. You may also use more complex expressions: 'can register = ${user.age > 13}'.

## format your strings

Format specifiers similar to those in C's printf() are also supported. f, g, x, o, b, etc. are optional and specify the output format.

To use a format specifier, follow this pattern:

```golang
${varname:[flags][width][.precision][type]}
```

flags: may be zero or more of the following: - to left-align output within the field, 0 to use 0 as the padding character instead of the default space character.

Note

- width: may be an integer value describing the minimum width of total field to output.
- precision: an integer value preceded by a . will guarantee that many digits after the decimal point, if the input variable is a float. Ignored if variable is an integer.
- type: f and F specify the input is a float and should be rendered as such, e and E specify the input is a float and should be rendered as an exponent (partially broken), g and G specify the input is a float--the renderer will use floating point notation for small values and exponent notation for large values, d specifies the input is an integer and should be rendered in base-10 digits, x and X require an integer and will render it as hexadecimal digits, o requires an integer and will render it as octal digits, b requires an integer and will render it as binary digits, s requires a string (almost never used).

```golang
x := 123.4567
println('[${x:.2}]') // round to two decimal places => [123.46]
println('[${x:10}]') // right-align with spaces on the left => [   123.457]
println('[${int(x):-10}]') // left-align with spaces on the right => [123       ]
println('[${int(x):010}]') // pad with zeros on the left => [0000000123]
println('[${int(x):b}]') // output as binary => [1111011]
println('[${int(x):o}]') // output as octal => [173]
println('[${int(x):X}]') // output as uppercase hex => [7B]

println('[${10.0000:.2}]') // remove insignificant 0s at the end => [10]
println('[${10.0000:.2f}]') // do show the 0s at the end, even though they do not change the number => [10.00]
V also has r and R switches, which will repeat the string the specified amount of times.

println('[${'abc':3r}]') // [abcabcabc]
println('[${'abc':3R}]') // [ABCABCABC]
```

## use colors

```golang
import freeflowuniverse.crystallib.ui.console

name:="some name"
pid:=111
state:=running
green:=console.color_fg(.green)
yellow:=console.color_fg(.yellow)
reset:=console.reset
println(" - screen:${green}${name:-20}${reset} pid:${yellow}${pid:-10}${reset} state:${green}${state}${reset}")


```