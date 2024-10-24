# V Documentation

## Comments

```v
// This is a single line comment.
/*
This is a multiline comment.
   /* It can be nested. */
*/
```

## Functions

```v
fn main() {
	println(add(77, 33))
	println(sub(100, 50))
}

fn add(x int, y int) int {
	return x + y
}

fn sub(x int, y int) int {
	return x - y
}
```

Again, the type comes after the argument's name.

Just like in Go and C, functions cannot be overloaded.
This simplifies the code and improves maintainability and readability.

### Hoisting

Functions can be used before their declaration:
`add` and `sub` are declared after `main`, but can still be called from `main`.
This is true for all declarations in V and eliminates the need for header files
or thinking about the order of files and declarations.

### Returning multiple values

```v
fn foo() (int, int) {
	return 2, 3
}

a, b := foo()
println(a) // 2
println(b) // 3
c, _ := foo() // ignore values using `_`
```

## Symbol visibility

```v
pub fn public_function() {
}

fn private_function() {
}
```

Functions are private (not exported) by default.
To allow other [modules](#module-imports) to use them, prepend `pub`. The same applies
to [structs](#structs), [constants](#constants) and [types](#type-declarations).

> [!NOTE]
> `pub` can only be used from a named module.
> For information about creating a module, see [Modules](#modules).

## Variables

```v
name := 'Bob'
age := 20
large_number := i64(9999999999)
println(name)
println(age)
println(large_number)
```

Variables are declared and initialized with `:=`. This is the only
way to declare variables in V. This means that variables always have an initial
value.

The variable's type is inferred from the value on the right hand side.
To choose a different type, use type conversion:
the expression `T(v)` converts the value `v` to the
type `T`.

Unlike most other languages, V only allows defining variables in functions.
By default V does not allow **global variables**. See more [details](#global-variables).

For consistency across different code bases, all variable and function names
must use the `snake_case` style, as opposed to type names, which must use `PascalCase`.

### Mutable variables

```v
mut age := 20
println(age)
age = 21
println(age)
```

To change the value of the variable use `=`. In V, variables are
immutable by default.
To be able to change the value of the variable, you have to declare it with `mut`.

Try compiling the program above after removing `mut` from the first line.

### Initialization vs assignment

Note the (important) difference between `:=` and `=`.
`:=` is used for declaring and initializing, `=` is used for assigning.

```v failcompile
fn main() {
	age = 21
}
```

This code will not compile, because the variable `age` is not declared.
All variables need to be declared in V.

```v
fn main() {
	age := 21
}
```

The values of multiple variables can be changed in one line.
In this way, their values can be swapped without an intermediary variable.

```v
mut a := 0
mut b := 1
println('${a}, ${b}') // 0, 1
a, b = b, a
println('${a}, ${b}') // 1, 0
```

### Warnings and declaration errors

In development mode the compiler will warn you that you haven't used the variable
(you'll get an "unused variable" warning).
In production mode (enabled by passing the `-prod` flag to v – `v -prod foo.v`)
it will not compile at all (like in Go).
```v
fn main() {
	a := 10
	// warning: unused variable `a`
}
```

To ignore values returned by a function `_` can be used
```v
fn foo() (int, int) {
	return 2, 3
}

fn main() {
	c, _ := foo()
	print(c)
	// no warning about unused variable returned by foo.
}
```

Unlike most languages, variable shadowing is not allowed. Declaring a variable with a name
that is already used in a parent scope will cause a compilation error.
```v failcompile nofmt
fn main() {
	a := 10
	if true {
		a := 20 // error: redefinition of `a`
	}
}
```
While variable shadowing is not allowed, field shadowing is allowed.
```v
pub struct Dimension {
	width  int = -1
	height int = -1
}

pub struct Test {
	Dimension
	width int = 100
	// height int
}

fn main() {
	test := Test{}
	println('${test.width} ${test.height} ${test.Dimension.width}') // 100 -1 -1
}
```
## V Types

### Primitive types

```v ignore
bool

string

i8    i16  int  i64      i128 (soon)
u8    u16  u32  u64      u128 (soon)

rune // represents a Unicode code point

f32 f64

isize, usize // platform-dependent, the size is how many bytes it takes to reference any location in memory

voidptr // this one is mostly used for [C interoperability](#v-and-c)

any // similar to C's void* and Go's interface{}
```

> [!NOTE]
> Unlike C and Go, `int` is always a 32 bit integer.

There is an exception to the rule that all operators
in V must have values of the same type on both sides. A small primitive type
on one side can be automatically promoted if it fits
completely into the data range of the type on the other side.
These are the allowed possibilities:

```v ignore
   i8 → i16 → int → i64
                  ↘     ↘
                    f32 → f64
                  ↗     ↗
   u8 → u16 → u32 → u64 ⬎
      ↘     ↘     ↘      ptr
   i8 → i16 → int → i64 ⬏
```

An `int` value for example can be automatically promoted to `f64`
or `i64` but not to `u32`. (`u32` would mean loss of the sign for
negative values).
Promotion from `int` to `f32`, however, is currently done automatically
(but can lead to precision loss for large values).

Literals like `123` or `4.56` are treated in a special way. They do
not lead to type promotions, however they default to `int` and `f64`
respectively, when their type has to be decided:

```v nofmt
u := u16(12)
v := 13 + u    // v is of type `u16` - no promotion
x := f32(45.6)
y := x + 3.14  // y is of type `f32` - no promotion
a := 75        // a is of type `int` - default for int literal
b := 14.7      // b is of type `f64` - default for float literal
c := u + a     // c is of type `int` - automatic promotion of `u`'s value
d := b + x     // d is of type `f64` - automatic promotion of `x`'s value
```

### Strings

```v nofmt
name := 'Bob'
assert name.len == 3       // will print 3
assert name[0] == u8(66) // indexing gives a byte, u8(66) == `B`
assert name[1..3] == 'ob'  // slicing gives a string 'ob'

// escape codes
windows_newline := '\r\n'      // escape special characters like in C
assert windows_newline.len == 2

// arbitrary bytes can be directly specified using `\x##` notation where `#` is
// a hex digit
aardvark_str := '\x61ardvark'
assert aardvark_str == 'aardvark'
assert '\xc0'[0] == u8(0xc0)

// or using octal escape `\###` notation where `#` is an octal digit
aardvark_str2 := '\141ardvark'
assert aardvark_str2 == 'aardvark'

// Unicode can be specified directly as `\u####` where # is a hex digit
// and will be converted internally to its UTF-8 representation
star_str := '\u2605' // ★
assert star_str == '★'
assert star_str == '\xe2\x98\x85' // UTF-8 can be specified this way too.
```

In V, a string is a read-only array of bytes. All Unicode characters are encoded using UTF-8:

```v
s := 'hello 🌎' // emoji takes 4 bytes
assert s.len == 10

arr := s.bytes() // convert `string` to `[]u8`
assert arr.len == 10

s2 := arr.bytestr() // convert `[]u8` to `string`
assert s2 == s
```

String values are immutable. You cannot mutate elements:

```v failcompile
mut s := 'hello 🌎'
s[0] = `H` // not allowed
```

> error: cannot assign to `s[i]` since V strings are immutable

Note that indexing a string will produce a `u8` (byte), not a `rune` nor another `string`. Indexes
correspond to _bytes_ in the string, not Unicode code points. If you want to convert the `u8` to a
`string`, use the `.ascii_str()` method on the `u8`:

```v
country := 'Netherlands'
println(country[0]) // Output: 78
println(country[0].ascii_str()) // Output: N
```

Both single and double quotes can be used to denote strings. For consistency, `vfmt` converts double
quotes to single quotes unless the string contains a single quote character.

For raw strings, prepend `r`. Escape handling is not done for raw strings:

```v
s := r'hello\nworld' // the `\n` will be preserved as two characters
println(s) // "hello\nworld"
```

Strings can be easily converted to integers:

```v
s := '42'
n := s.int() // 42

// all int literals are supported
assert '0xc3'.int() == 195
assert '0o10'.int() == 8
assert '0b1111_0000_1010'.int() == 3850
assert '-0b1111_0000_1010'.int() == -3850
```

For more advanced `string` processing and conversions, refer to the
[vlib/strconv](https://modules.vlang.io/strconv.html) module.

#### String interpolation

Basic interpolation syntax is pretty simple - use `${` before a variable name and `}` after. The
variable will be converted to a string and embedded into the literal:

```v
name := 'Bob'
println('Hello, ${name}!') // Hello, Bob!
```

It also works with fields: `'age = ${user.age}'`. You may also use more complex expressions:
`'can register = ${user.age > 13}'`.

Format specifiers similar to those in C's `printf()` are also supported. `f`, `g`, `x`, `o`, `b`,
etc. are optional and specify the output format. The compiler takes care of the storage size, so
there is no `hd` or `llu`.

To use a format specifier, follow this pattern:

`${varname:[flags][width][.precision][type]}`

- flags: may be zero or more of the following: `-` to left-align output within the field, `0` to use
  `0` as the padding character instead of the default `space` character.
  > **Note**
  >
  > V does not currently support the use of `'` or `#` as format flags, and V supports but
  > doesn't need `+` to right-align since that's the default.
- width: may be an integer value describing the minimum width of total field to output.
- precision: an integer value preceded by a `.` will guarantee that many digits after the decimal
  point without any insignificant trailing zeros. If displaying insignificant zero's is desired,
  append a `f` specifier to the precision value (see examples below). Applies only to float 
  variables and is ignored for integer variables.
- type: `f` and `F` specify the input is a float and should be rendered as such, `e` and `E` specify
  the input is a float and should be rendered as an exponent (partially broken), `g` and `G` specify
  the input is a float--the renderer will use floating point notation for small values and exponent
  notation for large values, `d` specifies the input is an integer and should be rendered in base-10
  digits, `x` and `X` require an integer and will render it as hexadecimal digits, `o` requires an
  integer and will render it as octal digits, `b` requires an integer and will render it as binary
  digits, `s` requires a string (almost never used).

  > **Note**
  >
  > When a numeric type can render alphabetic characters, such as hex strings or special values
  > like `infinity`, the lowercase version of the type forces lowercase alphabetics and the
  > uppercase version forces uppercase alphabetics.

  > **Note**
  >
  > In most cases, it's best to leave the format type empty. Floats will be rendered by
  > default as `g`, integers will be rendered by default as `d`, and `s` is almost always redundant.
  > There are only three cases where specifying a type is recommended:

- format strings are parsed at compile time, so specifying a type can help detect errors then
- format strings default to using lowercase letters for hex digits and the `e` in exponents. Use a
  uppercase type to force the use of uppercase hex digits and an uppercase `E` in exponents.
- format strings are the most convenient way to get hex, binary or octal strings from an integer.

See
[Format Placeholder Specification](https://en.wikipedia.org/wiki/Printf_format_string#Format_placeholder_specification)
for more information.

```v
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
```

V also has `r` and `R` switches, which will repeat the string the specified amount of times.

```v
println('[${'abc':3r}]') // [abcabcabc]
println('[${'abc':3R}]') // [ABCABCABC]
```

#### String operators

```v
name := 'Bob'
bobby := name + 'by' // + is used to concatenate strings
println(bobby) // "Bobby"
mut s := 'hello '
s += 'world' // `+=` is used to append to a string
println(s) // "hello world"
```

All operators in V must have values of the same type on both sides. You cannot concatenate an
integer to a string:

```v failcompile
age := 10
println('age = ' + age) // not allowed
```

> error: infix expr: cannot use `int` (right expression) as `string`

We have to either convert `age` to a `string`:

```v
age := 11
println('age = ' + age.str())
```

or use string interpolation (preferred):

```v
age := 12
println('age = ${age}')
```

See all methods of [string](https://modules.vlang.io/index.html#string)
and related modules [strings](https://modules.vlang.io/strings.html),
[strconv](https://modules.vlang.io/strconv.html).

### Runes

A `rune` represents a single Unicode character and is an alias for `u32`.
To denote them, use <code>`</code> (backticks) :

```v
rocket := `🚀`
```

A `rune` can be converted to a UTF-8 string by using the `.str()` method.

```v
rocket := `🚀`
assert rocket.str() == '🚀'
```

A `rune` can be converted to UTF-8 bytes by using the `.bytes()` method.

```v
rocket := `🚀`
assert rocket.bytes() == [u8(0xf0), 0x9f, 0x9a, 0x80]
```

Hex, Unicode, and Octal escape sequences also work in a `rune` literal:

```v
assert `\x61` == `a`
assert `\141` == `a`
assert `\u0061` == `a`

// multibyte literals work too
assert `\u2605` == `★`
assert `\u2605`.bytes() == [u8(0xe2), 0x98, 0x85]
assert `\xe2\x98\x85`.bytes() == [u8(0xe2), 0x98, 0x85]
assert `\342\230\205`.bytes() == [u8(0xe2), 0x98, 0x85]
```

Note that `rune` literals use the same escape syntax as strings, but they can only hold one unicode
character. Therefore, if your code does not specify a single Unicode character, you will receive an
error at compile time.

Also remember that strings are indexed as bytes, not runes, so beware:

```v
rocket_string := '🚀'
assert rocket_string[0] != `🚀`
assert 'aloha!'[0] == `a`
```

A string can be converted to runes by the `.runes()` method.

```v
hello := 'Hello World 👋'
hello_runes := hello.runes() // [`H`, `e`, `l`, `l`, `o`, ` `, `W`, `o`, `r`, `l`, `d`, ` `, `👋`]
assert hello_runes.string() == hello
```

### Numbers

```v
a := 123
```

This will assign the value of 123 to `a`. By default `a` will have the
type `int`.

You can also use hexadecimal, binary or octal notation for integer literals:

```v
a := 0x7B
b := 0b01111011
c := 0o173
```

All of these will be assigned the same value, 123. They will all have type
`int`, no matter what notation you used.

V also supports writing numbers with `_` as separator:

```v
num := 1_000_000 // same as 1000000
three := 0b0_11 // same as 0b11
float_num := 3_122.55 // same as 3122.55
hexa := 0xF_F // same as 255
oct := 0o17_3 // same as 0o173
```

If you want a different type of integer, you can use casting:

```v
a := i64(123)
b := u8(42)
c := i16(12345)
```

Assigning floating point numbers works the same way:

```v
f := 1.0
f1 := f64(3.14)
f2 := f32(3.14)
```

If you do not specify the type explicitly, by default float literals
will have the type of `f64`.

Float literals can also be declared as a power of ten:

```v
f0 := 42e1 // 420
f1 := 123e-2 // 1.23
f2 := 456e+2 // 45600
```

### Arrays

An array is a collection of data elements of the same type. An array literal is a
list of expressions surrounded by square brackets. An individual element can be
accessed using an *index* expression. Indexes start from `0`:

```v
mut nums := [1, 2, 3]
println(nums) // `[1, 2, 3]`
println(nums[0]) // `1`
println(nums[1]) // `2`

nums[1] = 5
println(nums) // `[1, 5, 3]`
```

<a id='array-operations'></a>

An element can be appended to the end of an array using the push operator `<<`.
It can also append an entire array.

```v
mut nums := [1, 2, 3]
nums << 4
println(nums) // "[1, 2, 3, 4]"

// append array
nums << [5, 6, 7]
println(nums) // "[1, 2, 3, 4, 5, 6, 7]"
```

```v
mut names := ['John']
names << 'Peter'
names << 'Sam'
// names << 10  <-- This will not compile. `names` is an array of strings.
```

`val in array` returns true if the array contains `val`. See [`in` operator](#in-operator).

```v
names := ['John', 'Peter', 'Sam']
println('Alex' in names) // "false"
```

#### Array Fields

There are two fields that control the "size" of an array:

* `len`: *length* - the number of pre-allocated and initialized elements in the array
* `cap`: *capacity* - the amount of memory space which has been reserved for elements,
  but not initialized or counted as elements. The array can grow up to this size without
  being reallocated. Usually, V takes care of this field automatically but there are
  cases where the user may want to do manual optimizations (see [below](#array-initialization)).

```v
mut nums := [1, 2, 3]
println(nums.len) // "3"
println(nums.cap) // "3" or greater
nums = [] // The array is now empty
println(nums.len) // "0"
```

`data` is a field (of type `voidptr`) with the address of the first
element. This is for low-level [`unsafe`](#memory-unsafe-code) code.

> [!NOTE]
> Fields are read-only and can't be modified by the user.

#### Array Initialization

The type of an array is determined by the first element:

* `[1, 2, 3]` is an array of ints (`[]int`).
* `['a', 'b']` is an array of strings (`[]string`).

The user can explicitly specify the type for the first element: `[u8(16), 32, 64, 128]`.
V arrays are homogeneous (all elements must have the same type).
This means that code like `[1, 'a']` will not compile.

The above syntax is fine for a small number of known elements but for very large or empty
arrays there is a second initialization syntax:

```v
mut a := []int{len: 10000, cap: 30000, init: 3}
```

This creates an array of 10000 `int` elements that are all initialized with `3`. Memory
space is reserved for 30000 elements. The parameters `len`, `cap` and `init` are optional;
`len` defaults to `0` and `init` to the default initialization of the element type (`0`
for numerical type, `''` for `string`, etc). The run time system makes sure that the
capacity is not smaller than `len` (even if a smaller value is specified explicitly):

```v
arr := []int{len: 5, init: -1}
// `arr == [-1, -1, -1, -1, -1]`, arr.cap == 5

// Declare an empty array:
users := []int{}
```

Setting the capacity improves performance of pushing elements to the array
as reallocations can be avoided:

```v
mut numbers := []int{cap: 1000}
println(numbers.len) // 0
// Now appending elements won't reallocate
for i in 0 .. 1000 {
	numbers << i
}
```

> [!NOTE]
> The above code uses a [range `for`](#range-for) statement.

You can initialize the array by accessing the `index` variable which gives
the index as shown here:

```v
count := []int{len: 4, init: index}
assert count == [0, 1, 2, 3]

mut square := []int{len: 6, init: index * index}
// square == [0, 1, 4, 9, 16, 25]
```

#### Array Types

An array can be of these types:

| Types        | Example Definition                   |
|--------------|--------------------------------------|
| Number       | `[]int,[]i64`                        |
| String       | `[]string`                           |
| Rune         | `[]rune`                             |
| Boolean      | `[]bool`                             |
| Array        | `[][]int`                            |
| Struct       | `[]MyStructName`                     |
| Channel      | `[]chan f64`                         |
| Function     | `[]MyFunctionType` `[]fn (int) bool` |
| Interface    | `[]MyInterfaceName`                  |
| Sum Type     | `[]MySumTypeName`                    |
| Generic Type | `[]T`                                |
| Map          | `[]map[string]f64`                   |
| Enum         | `[]MyEnumType`                       |
| Alias        | `[]MyAliasTypeName`                  |
| Thread       | `[]thread int`                       |
| Reference    | `[]&f64`                             |
| Shared       | `[]shared MyStructType`              |

**Example Code:**

This example uses [Structs](#structs) and [Sum Types](#sum-types) to create an array
which can handle different types (e.g. Points, Lines) of data elements.

```v
struct Point {
	x int
	y int
}

struct Line {
	p1 Point
	p2 Point
}

type ObjectSumType = Line | Point

mut object_list := []ObjectSumType{}
object_list << Point{1, 1}
object_list << Line{
	p1: Point{3, 3}
	p2: Point{4, 4}
}
dump(object_list)
/*
object_list: [ObjectSumType(Point{
    x: 1
    y: 1
}), ObjectSumType(Line{
    p1: Point{
        x: 3
        y: 3
    }
    p2: Point{
        x: 4
        y: 4
    }
})]
*/
```

#### Multidimensional Arrays

Arrays can have more than one dimension.

2d array example:

```v
mut a := [][]int{len: 2, init: []int{len: 3}}
a[0][1] = 2
println(a) // [[0, 2, 0], [0, 0, 0]]
```

3d array example:

```v
mut a := [][][]int{len: 2, init: [][]int{len: 3, init: []int{len: 2}}}
a[0][1][1] = 2
println(a) // [[[0, 0], [0, 2], [0, 0]], [[0, 0], [0, 0], [0, 0]]]
```

#### Array methods

All arrays can be easily printed with `println(arr)` and converted to a string
with `s := arr.str()`.

Copying the data from the array is done with `.clone()`:

```v
nums := [1, 2, 3]
nums_copy := nums.clone()
```

Arrays can be efficiently filtered and mapped with the `.filter()` and
`.map()` methods:

```v
nums := [1, 2, 3, 4, 5, 6]
even := nums.filter(it % 2 == 0)
println(even) // [2, 4, 6]
// filter can accept anonymous functions
even_fn := nums.filter(fn (x int) bool {
	return x % 2 == 0
})
println(even_fn)
```

```v
words := ['hello', 'world']
upper := words.map(it.to_upper())
println(upper) // ['HELLO', 'WORLD']
// map can also accept anonymous functions
upper_fn := words.map(fn (w string) string {
	return w.to_upper()
})
println(upper_fn) // ['HELLO', 'WORLD']
```

`it` is a builtin variable which refers to the element currently being
processed in filter/map methods.

Additionally, `.any()` and `.all()` can be used to conveniently test
for elements that satisfy a condition.

```v
nums := [1, 2, 3]
println(nums.any(it == 2)) // true
println(nums.all(it >= 2)) // false
```

There are further built-in methods for arrays:

* `a.repeat(n)` concatenates the array elements `n` times
* `a.insert(i, val)` inserts a new element `val` at index `i` and
  shifts all following elements to the right
* `a.insert(i, [3, 4, 5])` inserts several elements
* `a.prepend(val)` inserts a value at the beginning, equivalent to `a.insert(0, val)`
* `a.prepend(arr)` inserts elements of array `arr` at the beginning
* `a.trim(new_len)` truncates the length (if `new_length < a.len`, otherwise does nothing)
* `a.clear()` empties the array without changing `cap` (equivalent to `a.trim(0)`)
* `a.delete_many(start, size)` removes `size` consecutive elements from index `start`
  &ndash; triggers reallocation
* `a.delete(index)` equivalent to `a.delete_many(index, 1)`
* `a.delete_last()` removes the last element
* `a.first()` equivalent to `a[0]`
* `a.last()` equivalent to `a[a.len - 1]`
* `a.pop()` removes the last element and returns it
* `a.reverse()` makes a new array with the elements of `a` in reverse order
* `a.reverse_in_place()` reverses the order of elements in `a`
* `a.join(joiner)` concatenates an array of strings into one string
  using `joiner` string as a separator

See all methods of [array](https://modules.vlang.io/index.html#array)

See also [vlib/arrays](https://modules.vlang.io/arrays.html).

##### Sorting Arrays

Sorting arrays of all kinds is very simple and intuitive. Special variables `a` and `b`
are used when providing a custom sorting condition.

```v
mut numbers := [1, 3, 2]
numbers.sort() // 1, 2, 3
numbers.sort(a > b) // 3, 2, 1
```

```v
struct User {
	age  int
	name string
}

mut users := [User{21, 'Bob'}, User{20, 'Zarkon'}, User{25, 'Alice'}]
users.sort(a.age < b.age) // sort by User.age int field
users.sort(a.name > b.name) // reverse sort by User.name string field
```

V also supports custom sorting, through the `sort_with_compare` array method.
Which expects a comparing function which will define the sort order.
Useful for sorting on multiple fields at the same time by custom sorting rules.
The code below sorts the array ascending on `name` and descending `age`.

```v
struct User {
	age  int
	name string
}

mut users := [User{21, 'Bob'}, User{65, 'Bob'}, User{25, 'Alice'}]

custom_sort_fn := fn (a &User, b &User) int {
	// return -1 when a comes before b
	// return 0, when both are in same order
	// return 1 when b comes before a
	if a.name == b.name {
		if a.age < b.age {
			return 1
		}
		if a.age > b.age {
			return -1
		}
		return 0
	}
	if a.name < b.name {
		return -1
	} else if a.name > b.name {
		return 1
	}
	return 0
}
users.sort_with_compare(custom_sort_fn)
```

#### Array Slices

A slice is a part of a parent array. Initially it refers to the elements
between two indices separated by a `..` operator. The right-side index must
be greater than or equal to the left side index.

If a right-side index is absent, it is assumed to be the array length. If a
left-side index is absent, it is assumed to be 0.

```v
nums := [0, 10, 20, 30, 40]
println(nums[1..4]) // [10, 20, 30]
println(nums[..4]) // [0, 10, 20, 30]
println(nums[1..]) // [10, 20, 30, 40]
```

In V slices are arrays themselves (they are not distinct types). As a result
all array operations may be performed on them. E.g. they can be pushed onto an
array of the same type:

```v
array_1 := [3, 5, 4, 7, 6]
mut array_2 := [0, 1]
array_2 << array_1[..3]
println(array_2) // `[0, 1, 3, 5, 4]`
```

A slice is always created with the smallest possible capacity `cap == len` (see
[`cap` above](#array-initialization)) no matter what the capacity or length
of the parent array is. As a result it is immediately reallocated and copied to another
memory location when the size increases thus becoming independent from the
parent array (*copy on grow*). In particular pushing elements to a slice
does not alter the parent:

```v
mut a := [0, 1, 2, 3, 4, 5]

// Create a slice, that reuses the *same memory* as the parent array
// initially, without doing a new allocation:
mut b := unsafe { a[2..4] } // the contents of `b`, reuses the memory, used by the contents of `a`.

b[0] = 7 // Note that `b[0]` and `a[2]` refer to *the same element* in memory.
println(a) // `[0, 1, 7, 3, 4, 5]` - changing `b[0]` above, changed `a[2]` too.

// the content of `b` will get reallocated, to have room for the `9` element:
b << 9
// The content of `b`, is now reallocated, and fully independent from the content of `a`.

println(a) // `[0, 1, 7, 3, 4, 5]` - no change, since the content of `b` was reallocated,
// to a larger block, before the appending.

println(b) // `[7, 3, 9]` - the contents of `b`, after the reallocation, and appending of the `9`.
```

Appending to the parent array, may or may not make it independent from its child slices.
The behaviour depends on the *parent's capacity* and is predictable:

```v
mut a := []int{len: 5, cap: 6, init: 2}
mut b := unsafe { a[1..4] } // the contents of `b` uses part of the same memory, that is used by `a` too

a << 3
// still no reallocation of `a`, since `a.len` still fits in `a.cap`
b[2] = 13 // `a[3]` is modified, through the slice `b`.

a << 4
// the content of `a` has been reallocated now, and is independent from `b` (`cap` was exceeded by `len`)
b[1] = 3 // no change in `a`

println(a) // `[2, 2, 2, 13, 2, 3, 4]`
println(b) // `[2, 3, 13]`
```

You can call .clone() on the slice, if you *do* want to have an independent copy right away:

```v
mut a := [0, 1, 2, 3, 4, 5]
mut b := a[2..4].clone()
b[0] = 7 // Note: `b[0]` is NOT referring to `a[2]`, as it would have been, without the `.clone()`
println(a) // [0, 1, 2, 3, 4, 5]
println(b) // [7, 3]
```

##### Slices with negative indexes

V supports array and string slices with negative indexes.
Negative indexing starts from the end of the array towards the start,
for example `-3` is equal to `array.len - 3`.
Negative slices have a different syntax from normal slices, i.e. you need
to add a `gate` between the array name and the square bracket: `a#[..-3]`.
The `gate` specifies that this is a different type of slice and remember that
the result is "locked" inside the array.
The returned slice is always a valid array, though it may be empty:

```v
a := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
println(a#[-3..]) // [7, 8, 9]
println(a#[-20..]) // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
println(a#[-20..-8]) // [0, 1]
println(a#[..-3]) // [0, 1, 2, 3, 4, 5, 6]

// empty arrays
println(a#[-20..-10]) // []
println(a#[20..10]) // []
println(a#[20..30]) // []
```

#### Array method chaining

You can chain the calls of array methods like `.filter()` and `.map()` and use
the `it` built-in variable to achieve a classic `map/filter` functional paradigm:

```v
// using filter, map and negatives array slices
files := ['pippo.jpg', '01.bmp', '_v.txt', 'img_02.jpg', 'img_01.JPG']
filtered := files.filter(it#[-4..].to_lower() == '.jpg').map(it.to_upper())
// ['PIPPO.JPG', 'IMG_02.JPG', 'IMG_01.JPG']
```

### Fixed size arrays

V also supports arrays with fixed size. Unlike ordinary arrays, their
length is constant. You cannot append elements to them, nor shrink them.
You can only modify their elements in place.

However, access to the elements of fixed size arrays is more efficient,
they need less memory than ordinary arrays, and unlike ordinary arrays,
their data is on the stack, so you may want to use them as buffers if you
do not want additional heap allocations.

Most methods are defined to work on ordinary arrays, not on fixed size arrays.
You can convert a fixed size array to an ordinary array with slicing:

```v
mut fnums := [3]int{} // fnums is a fixed size array with 3 elements.
fnums[0] = 1
fnums[1] = 10
fnums[2] = 100
println(fnums) // => [1, 10, 100]
println(typeof(fnums).name) // => [3]int

fnums2 := [1, 10, 100]! // short init syntax that does the same (the syntax will probably change)

anums := fnums[..] // same as `anums := fnums[0..fnums.len]`
println(anums) // => [1, 10, 100]
println(typeof(anums).name) // => []int
```

Note that slicing will cause the data of the fixed size array to be copied to
the newly created ordinary array.

### Maps

```v
mut m := map[string]int{} // a map with `string` keys and `int` values
m['one'] = 1
m['two'] = 2
println(m['one']) // "1"
println(m['bad_key']) // "0"
println('bad_key' in m) // Use `in` to detect whether such key exists
println(m.keys()) // ['one', 'two']
m.delete('two')
```

Maps can have keys of type string, rune, integer, float or voidptr.

The whole map can be initialized using this short syntax:

```v
numbers := {
	'one': 1
	'two': 2
}
println(numbers)
```

If a key is not found, a zero value is returned by default:

```v
sm := {
	'abc': 'xyz'
}
val := sm['bad_key']
println(val) // ''
```

```v
intm := {
	1: 1234
	2: 5678
}
s := intm[3]
println(s) // 0
```

It's also possible to use an `or {}` block to handle missing keys:

```v
mm := map[string]int{}
val := mm['bad_key'] or { panic('key not found') }
```

You can also check, if a key is present, and get its value, if it was present, in one go:

```v
m := {
	'abc': 'def'
}
if v := m['abc'] {
	println('the map value for that key is: ${v}')
}
```

The same option check applies to arrays:

```v
arr := [1, 2, 3]
large_index := 999
val := arr[large_index] or { panic('out of bounds') }
println(val)
// you can also do this, if you want to *propagate* the access error:
val2 := arr[333]!
println(val2)
```

V also supports nested maps:

```v
mut m := map[string]map[string]int{}
m['greet'] = {
	'Hello': 1
}
m['place'] = {
	'world': 2
}
m['code']['orange'] = 123
print(m)
```

Maps are ordered by insertion, like dictionaries in Python. The order is a
guaranteed language feature. This may change in the future.

See all methods of
[map](https://modules.vlang.io/index.html#map)
and
[maps](https://modules.vlang.io/maps.html).

### Map update syntax

As with structs, V lets you initialise a map with an update applied on top of
another map:

```v
const base_map = {
	'a': 4
	'b': 5
}

foo := {
	...base_map
	'b': 88
	'c': 99
}

println(foo) // {'a': 4, 'b': 88, 'c': 99}
```

This is functionally equivalent to cloning the map and updating it, except that
you don't have to declare a mutable variable:

```v failcompile
// same as above (except mutable)
mut foo := base_map.clone()
foo['b'] = 88
foo['c'] = 99
```

## Module imports

For information about creating a module, see [Modules](#modules).

Modules can be imported using the `import` keyword:

```v
import os

fn main() {
	// read text from stdin
	name := os.input('Enter your name: ')
	println('Hello, ${name}!')
}
```

This program can use any public definitions from the `os` module, such
as the `input` function. See the [standard library](https://modules.vlang.io/)
documentation for a list of common modules and their public symbols.

By default, you have to specify the module prefix every time you call an external function.
This may seem verbose at first, but it makes code much more readable
and easier to understand - it's always clear which function from
which module is being called. This is especially useful in large code bases.

Cyclic module imports are not allowed, like in Go.

### Selective imports

You can also import specific functions and types from modules directly:

```v
import os { input }

fn main() {
	// read text from stdin
	name := input('Enter your name: ')
	println('Hello, ${name}!')
}
```

> [!NOTE]
> This will import the module as well. Also, this is not allowed for
> constants - they must always be prefixed.

You can import several specific symbols at once:

```v
import os { input, user_os }

name := input('Enter your name: ')
println('Name: ${name}')
current_os := user_os()
println('Your OS is ${current_os}.')
```

### Module import aliasing

Any imported module name can be aliased using the `as` keyword:

> [!NOTE]
> This example will not compile unless you have created `mymod/sha256/somename.v`
> (submodule names are determined by their path, not by the names of the .v file(s) in them).

```v failcompile
import crypto.sha256
import mymod.sha256 as mysha256

fn main() {
	v_hash := sha256.sum('hi'.bytes()).hex()
	my_hash := mysha256.sum('hi'.bytes()).hex()
	assert my_hash == v_hash
}
```

You cannot alias an imported function or type.
However, you _can_ redeclare a type.

```v
import time
import math

type MyTime = time.Time

fn (mut t MyTime) century() int {
	return int(1.0 + math.trunc(f64(t.year) * 0.009999794661191))
}

fn main() {
	mut my_time := MyTime{
		year:  2020
		month: 12
		day:   25
	}
	println(time.new(my_time).utc_string())
	println('Century: ${my_time.century()}')
}
```

## Statements & expressions

### If

```v
a := 10
b := 20
if a < b {
	println('${a} < ${b}')
} else if a > b {
	println('${a} > ${b}')
} else {
	println('${a} == ${b}')
}
```

`if` statements are pretty straightforward and similar to most other languages.
Unlike other C-like languages,
there are no parentheses surrounding the condition and the braces are always required.

#### `If` expressions
Unlike C, V does not have a ternary operator, that would allow you to do: `x = c ? 1 : 2` .
Instead, it has a bit more verbose, but also clearer to read, ability to use `if` as an
expression. The direct translation in V of the ternary construct above, assuming `c` is a
boolean condition, would be: `x = if c { 1 } else { 2 }`.

Here is another example:
```v
num := 777
s := if num % 2 == 0 { 'even' } else { 'odd' }
println(s)
// "odd"
```

You can use multiple statements in each of the branches of an `if` expression, followed by a final
value, that will become the value of the entire `if` expression, when it takes that branch:
```v
n := arguments().len
x := if n > 2 {
	dump(arguments())
	42
} else {
	println('something else')
	100
}
dump(x)
```

#### `If` unwrapping
Anywhere you can use `or {}`, you can also use "if unwrapping". This binds the unwrapped value
of an expression to a variable when that expression is not none nor an error.

```v
m := {
	'foo': 'bar'
}

// handle missing keys
if v := m['foo'] {
	println(v) // bar
} else {
	println('not found')
}
```

```v
fn res() !int {
	return 42
}

// functions that return a result type
if v := res() {
	println(v)
}
```

```v
struct User {
	name string
}

arr := [User{'John'}]

// if unwrapping with assignment of a variable
u_name := if v := arr[0] {
	v.name
} else {
	'Unnamed'
}
println(u_name) // John
```

#### Type checks and casts

You can check the current type of a sum type using `is` and its negated form `!is`.

You can do it either in an `if`:

```v cgen
struct Abc {
	val string
}

struct Xyz {
	foo string
}

type Alphabet = Abc | Xyz

x := Alphabet(Abc{'test'}) // sum type
if x is Abc {
	// x is automatically cast to Abc and can be used here
	println(x)
}
if x !is Abc {
	println('Not Abc')
}
```

or using `match`:

```v oksyntax
match x {
	Abc {
		// x is automatically cast to Abc and can be used here
		println(x)
	}
	Xyz {
		// x is automatically cast to Xyz and can be used here
		println(x)
	}
}
```

This works also with struct fields:

```v
struct MyStruct {
	x int
}

struct MyStruct2 {
	y string
}

type MySumType = MyStruct | MyStruct2

struct Abc {
	bar MySumType
}

x := Abc{
	bar: MyStruct{123} // MyStruct will be converted to MySumType type automatically
}
if x.bar is MyStruct {
	// x.bar is automatically cast
	println(x.bar)
} else if x.bar is MyStruct2 {
	new_var := x.bar as MyStruct2
	// ... or you can use `as` to create a type cast an alias manually:
	println(new_var)
}
match x.bar {
	MyStruct {
		// x.bar is automatically cast
		println(x.bar)
	}
	else {}
}
```

Mutable variables can change, and doing a cast would be unsafe.
However, sometimes it's useful to type cast despite mutability.
In such cases the developer must mark the expression with the `mut` keyword
to tell the compiler that they know what they're doing.

It works like this:

```v oksyntax
mut x := MySumType(MyStruct{123})
if mut x is MyStruct {
	// x is cast to MyStruct even if it's mutable
	// without the mut keyword that wouldn't work
	println(x)
}
// same with match
match mut x {
	MyStruct {
		// x is cast to MyStruct even if it's mutable
		// without the mut keyword that wouldn't work
		println(x)
	}
}
```

### Match

```v
os := 'windows'
print('V is running on ')
match os {
	'darwin' { println('macOS.') }
	'linux' { println('Linux.') }
	else { println(os) }
}
```

A match statement is a shorter way to write a sequence of `if - else` statements.
When a matching branch is found, the following statement block will be run.
The else branch will be run when no other branches match.

```v
number := 2
s := match number {
	1 { 'one' }
	2 { 'two' }
	else { 'many' }
}
```

A match statement can also to be used as an `if - else if - else` alternative:

```v
match true {
	2 > 4 { println('if') }
	3 == 4 { println('else if') }
	2 == 2 { println('else if2') }
	else { println('else') }
}
// 'else if2' should be printed
```

or as an `unless` alternative: [unless Ruby](https://www.tutorialspoint.com/ruby/ruby_if_else.htm)

```v
match false {
	2 > 4 { println('if') }
	3 == 4 { println('else if') }
	2 == 2 { println('else if2') }
	else { println('else') }
}
// 'if' should be printed
```

A match expression returns the value of the final expression from the matching branch.

```v
enum Color {
	red
	blue
	green
}

fn is_red_or_blue(c Color) bool {
	return match c {
		.red, .blue { true } // comma can be used to test multiple values
		.green { false }
	}
}
```

A match statement can also be used to branch on the variants of an `enum`
by using the shorthand `.variant_here` syntax. An `else` branch is not allowed
when all the branches are exhaustive.

```v
c := `v`
typ := match c {
	`0`...`9` { 'digit' }
	`A`...`Z` { 'uppercase' }
	`a`...`z` { 'lowercase' }
	else { 'other' }
}
println(typ)
// 'lowercase'
```

You can also use ranges as `match` patterns. If the value falls within the range
of a branch, that branch will be executed.

Note that the ranges use `...` (three dots) rather than `..` (two dots). This is
because the range is *inclusive* of the last element, rather than exclusive
(as `..` ranges are). Using `..` in a match branch will throw an error.

```v
const start = 1

const end = 10

c := 2
num := match c {
	start...end {
		1000
	}
	else {
		0
	}
}
println(num)
// 1000
```

Constants can also be used in the range branch expressions.

> [!NOTE]
> `match` as an expression is not usable in `for` loop and `if` statements.

### In operator

`in` allows to check whether an array or a map contains an element.
To do the opposite, use `!in`.

```v
nums := [1, 2, 3]
println(1 in nums) // true
println(4 !in nums) // true
```

> [!NOTE]
> `in` checks if map contains a key, not a value.

```v
m := {
	'one': 1
	'two': 2
}

println('one' in m) // true
println('three' !in m) // true
```

It's also useful for writing boolean expressions that are clearer and more compact:

```v
enum Token {
	plus
	minus
	div
	mult
}

struct Parser {
	token Token
}

parser := Parser{}
if parser.token == .plus || parser.token == .minus || parser.token == .div || parser.token == .mult {
	// ...
}
if parser.token in [.plus, .minus, .div, .mult] {
	// ...
}
```

V optimizes such expressions,
so both `if` statements above produce the same machine code and no arrays are created.

### For loop

V has only one looping keyword: `for`, with several forms.

#### `for`/`in`

This is the most common form. You can use it with an array, map or
numeric range.

##### Array `for`

```v
numbers := [1, 2, 3, 4, 5]
for num in numbers {
	println(num)
}
names := ['Sam', 'Peter']
for i, name in names {
	println('${i}) ${name}')
	// Output: 0) Sam
	//         1) Peter
}
```

The `for value in arr` form is used for going through elements of an array.
If an index is required, an alternative form `for index, value in arr` can be used.

Note that the value is read-only.
If you need to modify the array while looping, you need to declare the element as mutable:

```v
mut numbers := [0, 1, 2]
for mut num in numbers {
	num++
}
println(numbers) // [1, 2, 3]
```

When an identifier is just a single underscore, it is ignored.

##### Custom iterators

Types that implement a `next` method returning an `Option` can be iterated
with a `for` loop.

```v
struct SquareIterator {
	arr []int
mut:
	idx int
}

fn (mut iter SquareIterator) next() ?int {
	if iter.idx >= iter.arr.len {
		return none
	}
	defer {
		iter.idx++
	}
	return iter.arr[iter.idx] * iter.arr[iter.idx]
}

nums := [1, 2, 3, 4, 5]
iter := SquareIterator{
	arr: nums
}
for squared in iter {
	println(squared)
}
```

The code above prints:

```
1
4
9
16
25
```

##### Map `for`

```v
m := {
	'one': 1
	'two': 2
}
for key, value in m {
	println('${key} -> ${value}')
	// Output: one -> 1
	//         two -> 2
}
```

Either key or value can be ignored by using a single underscore as the identifier.

```v
m := {
	'one': 1
	'two': 2
}
// iterate over keys
for key, _ in m {
	println(key)
	// Output: one
	//         two
}
// iterate over values
for _, value in m {
	println(value)
	// Output: 1
	//         2
}
```

##### Range `for`

```v
// Prints '01234'
for i in 0 .. 5 {
	print(i)
}
```

`low..high` means an *exclusive* range, which represents all values
from `low` up to *but not including* `high`.

> [!NOTE]
> This exclusive range notation and zero-based indexing follow principles of
logical consistency and error reduction. As Edsger W. Dijkstra outlines in
'Why Numbering Should Start at Zero'
([EWD831](https://www.cs.utexas.edu/users/EWD/transcriptions/EWD08xx/EWD831.html)),
zero-based indexing aligns the index with the preceding elements in a sequence,
simplifying handling and minimizing errors, especially with adjacent subsequences.
This logical and efficient approach shapes our language design, emphasizing clarity
and reducing confusion in programming.

#### Condition `for`

```v
mut sum := 0
mut i := 0
for i <= 100 {
	sum += i
	i++
}
println(sum) // "5050"
```

This form of the loop is similar to `while` loops in other languages.
The loop will stop iterating once the boolean condition evaluates to false.
Again, there are no parentheses surrounding the condition, and the braces are always required.

#### Bare `for`

```v
mut num := 0
for {
	num += 2
	if num >= 10 {
		break
	}
}
println(num) // "10"
```

The condition can be omitted, resulting in an infinite loop.

#### C `for`

```v
for i := 0; i < 10; i += 2 {
	// Don't print 6
	if i == 6 {
		continue
	}
	println(i)
}
```

Finally, there's the traditional C style `for` loop. It's safer than the `while` form
because with the latter it's easy to forget to update the counter and get
stuck in an infinite loop.

Here `i` doesn't need to be declared with `mut` since it's always going to be mutable by definition.

#### Labelled break & continue

`break` and `continue` control the innermost `for` loop by default.
You can also use `break` and `continue` followed by a label name to refer to an outer `for`
loop:

```v
outer: for i := 4; true; i++ {
	println(i)
	for {
		if i < 7 {
			continue outer
		} else {
			break outer
		}
	}
}
```

The label must immediately precede the outer loop.
The above code prints:

```
4
5
6
7
```

### Defer

A defer statement defers the execution of a block of statements
until the surrounding function returns.

```v
import os

fn read_log() {
	mut ok := false
	mut f := os.open('log.txt') or { panic(err) }
	defer {
		f.close()
	}
	// ...
	if !ok {
		// defer statement will be called here, the file will be closed
		return
	}
	// ...
	// defer statement will be called here, the file will be closed
}
```

If the function returns a value the `defer` block is executed *after* the return
expression is evaluated:

```v
import os

enum State {
	normal
	write_log
	return_error
}

// write log file and return number of bytes written

fn write_log(s State) !int {
	mut f := os.create('log.txt')!
	defer {
		f.close()
	}
	if s == .write_log {
		// `f.close()` will be called after `f.write()` has been
		// executed, but before `write_log()` finally returns the
		// number of bytes written to `main()`
		return f.writeln('This is a log file')
	} else if s == .return_error {
		// the file will be closed after the `error()` function
		// has returned - so the error message will still report
		// it as open
		return error('nothing written; file open: ${f.is_opened}')
	}
	// the file will be closed here, too
	return 0
}

fn main() {
	n := write_log(.return_error) or {
		println('Error: ${err}')
		0
	}
	println('${n} bytes written')
}
```

To access the result of the function inside a `defer` block the `$res()` expression can be used.
`$res()` is only used when a single value is returned, while on multi-return the `$res(idx)`
is parameterized.

```v ignore
fn (mut app App) auth_middleware() bool {
	defer {
		if !$res() {
			app.response.status_code = 401
			app.response.body = 'Unauthorized'
		}
	}
	header := app.get_header('Authorization')
	if header == '' {
		return false
	}
	return true
}

fn (mut app App) auth_with_user_middleware() (bool, string) {
	defer {
		if !$res(0) {
			app.response.status_code = 401
			app.response.body = 'Unauthorized'
		} else {
			app.user = $res(1)
		}
	}
	header := app.get_header('Authorization')
	if header == '' {
		return false, ''
	}
	return true, 'TestUser'
}
```

### Goto

V allows unconditionally jumping to a label with `goto`. The label name must be contained
within the same function as the `goto` statement. A program may `goto` a label outside
or deeper than the current scope. `goto` allows jumping past variable initialization or
jumping back to code that accesses memory that has already been freed, so it requires
`unsafe`.

```v ignore
if x {
	// ...
	if y {
		unsafe {
			goto my_label
		}
	}
	// ...
}
my_label:
```

`goto` should be avoided, particularly when `for` can be used instead.
[Labelled break/continue](#labelled-break--continue) can be used to break out of
a nested loop, and those do not risk violating memory-safety.

## Structs

```v
struct Point {
	x int
	y int
}

mut p := Point{
	x: 10
	y: 20
}
println(p.x) // Struct fields are accessed using a dot
// Alternative literal syntax
p = Point{10, 20}
assert p.x == 10
```

### Heap structs

Structs are allocated on the stack. To allocate a struct on the heap
and get a [reference](#references) to it, use the `&` prefix:

```v
struct Point {
	x int
	y int
}

p := &Point{10, 10}
// References have the same syntax for accessing fields
println(p.x)
```

The type of `p` is `&Point`. It's a [reference](#references) to `Point`.
References are similar to Go pointers and C++ references.

```v
struct Foo {
mut:
	x int
}

fa := Foo{1}
mut a := fa
a.x = 2
assert fa.x == 1
assert a.x == 2

// fb := Foo{ 1 }
// mut b := &fb  // error: `fb` is immutable, cannot have a mutable reference to it
// b.x = 2

mut fc := Foo{1}
mut c := &fc
c.x = 2
assert fc.x == 2
assert c.x == 2
println(fc) // Foo{ x: 2 }
println(c) // &Foo{ x: 2 } // Note `&` prefixed.
```

see also [Stack and Heap](#stack-and-heap)

### Default field values

```v
struct Foo {
	n   int    // n is 0 by default
	s   string // s is '' by default
	a   []int  // a is `[]int{}` by default
	pos int = -1 // custom default value
}
```

All struct fields are zeroed by default during the creation of the struct.
Array and map fields are allocated.
In case of reference value, see [here](#structs-with-reference-fields).

It's also possible to define custom default values.

### Required fields

```v
struct Foo {
	n int @[required]
}
```

You can mark a struct field with the `[required]` [attribute](#attributes), to tell V that
that field must be initialized when creating an instance of that struct.

This example will not compile, since the field `n` isn't explicitly initialized:

```v failcompile
_ = Foo{}
```

<a id='short-struct-initialization-syntax'></a>

### Short struct literal syntax

```v
struct Point {
	x int
	y int
}

mut p := Point{
	x: 10
	y: 20
}
p = Point{
	x: 30
	y: 4
}
assert p.y == 4
//
// array: first element defines type of array
points := [Point{10, 20}, Point{20, 30}, Point{40, 50}]
println(points) // [Point{x: 10, y: 20}, Point{x: 20, y: 30}, Point{x: 40,y: 50}]
```

Omitting the struct name also works for returning a struct literal or passing one
as a function argument.

### Struct update syntax

V makes it easy to return a modified version of an object:

```v
struct User {
	name          string
	age           int
	is_registered bool
}

fn register(u User) User {
	return User{
		...u
		is_registered: true
	}
}

mut user := User{
	name: 'abc'
	age:  23
}
user = register(user)
println(user)
```

### Trailing struct literal arguments

V doesn't have default function arguments or named arguments, for that trailing struct
literal syntax can be used instead:

```v
@[params]
struct ButtonConfig {
	text        string
	is_disabled bool
	width       int = 70
	height      int = 20
}

struct Button {
	text   string
	width  int
	height int
}

fn new_button(c ButtonConfig) &Button {
	return &Button{
		width:  c.width
		height: c.height
		text:   c.text
	}
}

button := new_button(text: 'Click me', width: 100)
// the height is unset, so it's the default value
assert button.height == 20
```

As you can see, both the struct name and braces can be omitted, instead of:

```v oksyntax nofmt
new_button(ButtonConfig{text:'Click me', width:100})
```

This only works for functions that take a struct for the last argument.

> [!NOTE]
> Note the `[params]` tag is used to tell V, that the trailing struct parameter
> can be omitted *entirely*, so that you can write `button := new_button()`.
> Without it, you have to specify *at least* one of the field names, even if it
> has its default value, otherwise the compiler will produce this error message,
> when you call the function with no parameters:
> `error: expected 1 arguments, but got 0`.

### Access modifiers

Struct fields are private and immutable by default (making structs immutable as well).
Their access modifiers can be changed with
`pub` and `mut`. In total, there are 5 possible options:

```v
struct Foo {
	a int // private immutable (default)
mut:
	b int // private mutable
	c int // (you can list multiple fields with the same access modifier)
pub:
	d int // public immutable (readonly)
pub mut:
	e int // public, but mutable only in parent module
__global:
	// (not recommended to use, that's why the 'global' keyword starts with __)
	f int // public and mutable both inside and outside parent module
}
```

Private fields are available only inside the same [module](#modules), any attempt
to directly access them from another module will cause an error during compilation.
Public immutable fields are readonly everywhere.

### Anonymous structs

V supports anonymous structs: structs that don't have to be declared separately
with a struct name.

```v
struct Book {
	author struct {
		name string
		age  int
	}

	title string
}

book := Book{
	author: struct {
		name: 'Samantha Black'
		age:  24
	}
}
assert book.author.name == 'Samantha Black'
assert book.author.age == 24
```

### Static type methods

V now supports static type methods like `User.new()`. These are defined on a struct via
`fn [Type name].[function name]` and allow to organize all functions related to a struct:

```v oksyntax
struct User {}

fn User.new() User {
	return User{}
}

user := User.new()
```

This is an alternative to factory functions like `fn new_user() User {}` and should be used
instead.

> [!NOTE]
> Note, that these are not constructors, but simple functions. V doesn't have constructors or
> classes.

### `[noinit]` structs

V supports `[noinit]` structs, which are structs that cannot be initialised outside the module
they are defined in. They are either meant to be used internally or they can be used externally
through _factory functions_.

For an example, consider the following source in a directory `sample`:

```v oksyntax
module sample

@[noinit]
pub struct Information {
pub:
	data string
}

pub fn new_information(data string) !Information {
	if data.len == 0 || data.len > 100 {
		return error('data must be between 1 and 100 characters')
	}
	return Information{
		data: data
	}
}
```

Note that `new_information` is a _factory_ function. Now when we want to use this struct
outside the module:

```v okfmt
import sample

fn main() {
	// This doesn't work when the [noinit] attribute is present:
	// info := sample.Information{
	// 	data: 'Sample information.'
	// }

	// Use this instead:
	info := sample.new_information('Sample information.')!

	println(info)
}
```

### Methods

```v
struct User {
	age int
}

fn (u User) can_register() bool {
	return u.age > 16
}

user := User{
	age: 10
}
println(user.can_register()) // "false"
user2 := User{
	age: 20
}
println(user2.can_register()) // "true"
```

V doesn't have classes, but you can define methods on types.
A method is a function with a special receiver argument.
The receiver appears in its own argument list between the `fn` keyword and the method name.
Methods must be in the same module as the receiver type.

In this example, the `can_register` method has a receiver of type `User` named `u`.
The convention is not to use receiver names like `self` or `this`,
but a short, preferably one letter long, name.

### Embedded structs

V supports embedded structs.

```v
struct Size {
mut:
	width  int
	height int
}

fn (s &Size) area() int {
	return s.width * s.height
}

struct Button {
	Size
	title string
}
```

With embedding, the struct `Button` will automatically get all the fields and methods from
the struct `Size`, which allows you to do:

```v oksyntax
mut button := Button{
	title:  'Click me'
	height: 2
}

button.width = 3
assert button.area() == 6
assert button.Size.area() == 6
print(button)
```

output :

```
Button{
    Size: Size{
        width: 3
        height: 2
    }
    title: 'Click me'
}
```

Unlike inheritance, you cannot type cast between structs and embedded structs
(the embedding struct can also have its own fields, and it can also embed multiple structs).

If you need to access embedded structs directly, use an explicit reference like `button.Size`.

Conceptually, embedded structs are similar to [mixin](https://en.wikipedia.org/wiki/Mixin)s
in OOP, *NOT* base classes.

You can also initialize an embedded struct:

```v oksyntax
mut button := Button{
	Size: Size{
		width:  3
		height: 2
	}
}
```

or assign values:

```v oksyntax
button.Size = Size{
	width:  4
	height: 5
}
```

If multiple embedded structs have methods or fields with the same name, or if methods or fields
with the same name are defined in the struct, you can call methods or assign to variables in
the embedded struct like `button.Size.area()`.
When you do not specify the embedded struct name, the method of the outermost struct will be
targeted.

## Unions

Just like structs, unions support embedding.

```v
struct Rgba32_Component {
	r u8
	g u8
	b u8
	a u8
}

union Rgba32 {
	Rgba32_Component
	value u32
}

clr1 := Rgba32{
	value: 0x008811FF
}

clr2 := Rgba32{
	Rgba32_Component: Rgba32_Component{
		a: 128
	}
}

sz := sizeof(Rgba32)
unsafe {
	println('Size: ${sz}B,clr1.b: ${clr1.b},clr2.b: ${clr2.b}')
}
```

Output: `Size: 4B, clr1.b: 136, clr2.b: 0`

Union member access must be performed in an `unsafe` block.

> [!NOTE]
> Embedded struct arguments are not necessarily stored in the order listed.

## Functions 2

### Immutable function args by default

In V function arguments are immutable by default, and mutable args have to be
marked on call.

Since there are also no globals, that means that the return values of the functions,
are a function of their arguments only, and their evaluation has no side effects
(unless the function uses I/O).

Function arguments are immutable by default, even when [references](#references) are passed.

> [!NOTE]
> However, V is not a purely functional language.

There is a compiler flag to enable global variables (`-enable-globals`), but this is
intended for low-level applications like kernels and drivers.

### Mutable arguments

It is possible to modify function arguments by declaring them with the keyword `mut`:

```v
struct User {
	name string
mut:
	is_registered bool
}

fn (mut u User) register() {
	u.is_registered = true
}

mut user := User{}
println(user.is_registered) // "false"
user.register()
println(user.is_registered) // "true"
```

In this example, the receiver (which is just the first argument) is explicitly marked as mutable,
so `register()` can change the user object. The same works with non-receiver arguments:

```v
fn multiply_by_2(mut arr []int) {
	for i in 0 .. arr.len {
		arr[i] *= 2
	}
}

mut nums := [1, 2, 3]
multiply_by_2(mut nums)
println(nums)
// "[2, 4, 6]"
```

Note that you have to add `mut` before `nums` when calling this function. This makes
it clear that the function being called will modify the value.

It is preferable to return values instead of modifying arguments,
e.g. `user = register(user)` (or `user.register()`) instead of `register(mut user)`.
Modifying arguments should only be done in performance-critical parts of your application
to reduce allocations and copying.

For this reason V doesn't allow the modification of arguments with primitive types (e.g. integers).
Only more complex types such as arrays and maps may be modified.

### Variable number of arguments
V supports functions that receive an arbitrary, variable amounts of arguments, denoted with the
`...` prefix.
Below, `a ...int` refers to an arbitrary amount of parameters that will be collected
into an array named `a`.

```v
fn sum(a ...int) int {
	mut total := 0
	for x in a {
		total += x
	}
	return total
}

println(sum()) // 0
println(sum(1)) // 1
println(sum(2, 3)) // 5
// using array decomposition
a := [2, 3, 4]
println(sum(...a)) // <-- using prefix ... here. output: 9
b := [5, 6, 7]
println(sum(...b)) // output: 18
```

### Anonymous & higher order functions

```v
fn sqr(n int) int {
	return n * n
}

fn cube(n int) int {
	return n * n * n
}

fn run(value int, op fn (int) int) int {
	return op(value)
}

fn main() {
	// Functions can be passed to other functions
	println(run(5, sqr)) // "25"
	// Anonymous functions can be declared inside other functions:
	double_fn := fn (n int) int {
		return n + n
	}
	println(run(5, double_fn)) // "10"
	// Functions can be passed around without assigning them to variables:
	res := run(5, fn (n int) int {
		return n + n
	})
	println(res) // "10"
	// You can even have an array/map of functions:
	fns := [sqr, cube]
	println(fns[0](10)) // "100"
	fns_map := {
		'sqr':  sqr
		'cube': cube
	}
	println(fns_map['cube'](2)) // "8"
}
```

### Closures

V supports closures too.
This means that anonymous functions can inherit variables from the scope they were created in.
They must do so explicitly by listing all variables that are inherited.

```v oksyntax
my_int := 1
my_closure := fn [my_int] () {
	println(my_int)
}
my_closure() // prints 1
```

Inherited variables are copied when the anonymous function is created.
This means that if the original variable is modified after the creation of the function,
the modification won't be reflected in the function.

```v oksyntax
mut i := 1
func := fn [i] () int {
	return i
}
println(func() == 1) // true
i = 123
println(func() == 1) // still true
```

However, the variable can be modified inside the anonymous function.
The change won't be reflected outside, but will be in the later function calls.

```v oksyntax
fn new_counter() fn () int {
	mut i := 0
	return fn [mut i] () int {
		i++
		return i
	}
}

c := new_counter()
println(c()) // 1
println(c()) // 2
println(c()) // 3
```

If you need the value to be modified outside the function, use a reference.

```v oksyntax
mut i := 0
mut ref := &i
print_counter := fn [ref] () {
	println(*ref)
}

print_counter() // 0
i = 10
print_counter() // 10
```

### Parameter evaluation order

The evaluation order of the parameters of function calls is *NOT* guaranteed.
Take for example the following program:

```v
fn f(a1 int, a2 int, a3 int) {
	dump(a1 + a2 + a3)
}

fn main() {
	f(dump(100), dump(200), dump(300))
}
```

V currently does not guarantee that it will print 100, 200, 300 in that order.
The only guarantee is that 600 (from the body of `f`) will be printed after all of them.

This *may* change in V 1.0 .

## References

```v
struct Foo {}

fn (foo Foo) bar_method() {
	// ...
}

fn bar_function(foo Foo) {
	// ...
}
```

If a function argument is immutable (like `foo` in the examples above)
V can pass it either by value or by reference. The compiler will decide,
and the developer doesn't need to think about it.

You no longer need to remember whether you should pass the struct by value
or by reference.

You can ensure that the struct is always passed by reference by
adding `&`:

```v
struct Foo {
	abc int
}

fn (foo &Foo) bar() {
	println(foo.abc)
}
```

`foo` is still immutable and can't be changed. For that,
`(mut foo Foo)` must be used.

In general, V's references are similar to Go pointers and C++ references.
For example, a generic tree structure definition would look like this:

```v
struct Node[T] {
	val   T
	left  &Node[T]
	right &Node[T]
}
```

To dereference a reference, use the `*` operator, just like in C.

## Constants

```v
const pi = 3.14
const world = '世界'

println(pi)
println(world)
```

Constants are declared with `const`. They can only be defined
at the module level (outside of functions).
Constant values can never be changed. You can also declare a single
constant separately:

```v
const e = 2.71828
```

V constants are more flexible than in most languages. You can assign more complex values:

```v
struct Color {
	r int
	g int
	b int
}

fn rgb(r int, g int, b int) Color {
	return Color{
		r: r
		g: g
		b: b
	}
}

const numbers = [1, 2, 3]
const red = Color{
	r: 255
	g: 0
	b: 0
}
// evaluate function call at compile time*
const blue = rgb(0, 0, 255)

println(numbers)
println(red)
println(blue)
```

\* WIP - for now function calls are evaluated at program start-up

Global variables are not normally allowed, so this can be really useful.

**Modules**

Constants can be made public with `pub const`:

```v oksyntax
module mymodule

pub const golden_ratio = 1.61803

fn calc() {
	println(golden_ratio)
}
```

The `pub` keyword is only allowed before the `const` keyword and cannot be used inside
a `const ( )` block.

Outside from module main all constants need to be prefixed with the module name.

### Required module prefix

When naming constants, `snake_case` must be used. In order to distinguish consts
from local variables, the full path to consts must be specified. For example,
to access the PI const, full `math.pi` name must be used both outside the `math`
module, and inside it. That restriction is relaxed only for the `main` module
(the one containing your `fn main()`), where you can use the unqualified name of
constants defined there, i.e. `numbers`, rather than `main.numbers`.

vfmt takes care of this rule, so you can type `println(pi)` inside the `math` module,
and vfmt will automatically update it to `println(math.pi)`.

<!--
Many people prefer all caps consts: `TOP_CITIES`. This wouldn't work
well in V, because consts are a lot more powerful than in other languages.
They can represent complex structures, and this is used quite often since there
are no globals:

```v oksyntax
println('Top cities: ${top_cities.filter(.usa)}')
```
-->

## Builtin functions

Some functions are builtin like `println`. Here is the complete list:

```v ignore
fn print(s string) // prints anything on stdout
fn println(s string) // prints anything and a newline on stdout

fn eprint(s string) // same as print(), but uses stderr
fn eprintln(s string) // same as println(), but uses stderr

fn exit(code int) // terminates the program with a custom error code
fn panic(s string) // prints a message and backtraces on stderr, and terminates the program with error code 1
fn print_backtrace() // prints backtraces on stderr
```

> [!NOTE]
> Although the `print` functions take a string, V accepts other printable types too.
> See below for details.

There is also a special built-in function called [`dump`](#dumping-expressions-at-runtime).

### println

`println` is a simple yet powerful builtin function, that can print anything:
strings, numbers, arrays, maps, structs.

```v
struct User {
	name string
	age  int
}

println(1) // "1"
println('hi') // "hi"
println([1, 2, 3]) // "[1, 2, 3]"
println(User{ name: 'Bob', age: 20 }) // "User{name:'Bob', age:20}"
```

See also [Array methods](#array-methods).

<a id='custom-print-of-types'></a>

### Printing custom types

If you want to define a custom print value for your type, simply define a
`str() string` method:

```v
struct Color {
	r int
	g int
	b int
}

pub fn (c Color) str() string {
	return '{${c.r}, ${c.g}, ${c.b}}'
}

red := Color{
	r: 255
	g: 0
	b: 0
}
println(red)
```

### Dumping expressions at runtime

You can dump/trace the value of any V expression using `dump(expr)`.
For example, save this code sample as `factorial.v`, then run it with
`v run factorial.v`:

```v
fn factorial(n u32) u32 {
	if dump(n <= 1) {
		return dump(1)
	}
	return dump(n * factorial(n - 1))
}

fn main() {
	println(factorial(5))
}
```

You will get:

```
[factorial.v:2] n <= 1: false
[factorial.v:2] n <= 1: false
[factorial.v:2] n <= 1: false
[factorial.v:2] n <= 1: false
[factorial.v:2] n <= 1: true
[factorial.v:3] 1: 1
[factorial.v:5] n * factorial(n - 1): 2
[factorial.v:5] n * factorial(n - 1): 6
[factorial.v:5] n * factorial(n - 1): 24
[factorial.v:5] n * factorial(n - 1): 120
120
```

Note that `dump(expr)` will trace both the source location,
the expression itself, and the expression value.
