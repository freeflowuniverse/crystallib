
## Modules

Every file in the root of a folder is part of the same module.
Simple programs don't need to specify module name, in which case it defaults to 'main'.

See [symbol visibility](#symbol-visibility), [Access modifiers](#access-modifiers).

### Create modules

V is a very modular language. Creating reusable modules is encouraged and is
quite easy to do.
To create a new module, create a directory with your module's name containing
.v files with code:

```shell
cd ~/code/modules
mkdir mymodule
vim mymodule/myfile.v
```

```v failcompile
// myfile.v
module mymodule

// To export a function we have to use `pub`
pub fn say_hi() {
	println('hello from mymodule!')
}
```
All items inside a module can be used between the files of a module regardless of whether or
not they are prefaced with the `pub` keyword.
```v failcompile
// myfile2.v
module mymodule

pub fn say_hi_and_bye() {
	say_hi() // from myfile.v
	println('goodbye from mymodule')
}
```

You can now use `mymodule` in your code:

```v failcompile
import mymodule

fn main() {
	mymodule.say_hi()
	mymodule.say_hi_and_bye()
}
```

* Module names should be short, under 10 characters.
* Module names must use `snake_case`.
* Circular imports are not allowed.
* You can have as many .v files in a module as you want.
* You can create modules anywhere.
* All modules are compiled statically into a single executable.

### Special considerations for project folders

For the top level project folder (the one, compiled with `v .`), and *only*
that folder, you can have several .v files, that may be mentioning different modules
with `module main`, `module abc` etc

This is to ease the prototyping workflow in that folder:
- you can start developing some new project with a single .v file
- split functionality as necessary to different .v files in the same folder
- when that makes logical sense to be further organised, put them into their own directory module.

Note that in ordinary modules, all .v files must start with `module name_of_folder`.

### `init` functions

If you want a module to automatically call some setup/initialization code when it is imported,
you can define a module `init` function:

```v
fn init() {
	// your setup code here ...
}
```

The `init` function cannot be public - it will be called automatically by V, *just once*, no matter
how many times the module was imported in your program. This feature is particularly useful for
initializing a C library.

### `cleanup` functions

If you want a module to automatically call some cleanup/deinitialization code, when your program
ends, you can define a module `cleanup` function:

```v
fn cleanup() {
	// your deinitialisation code here ...
}
```

Just like the `init` function, the `cleanup` function for a module cannot be public - it will be
called automatically, when your program ends, once per module, even if the module was imported
transitively by other modules several times, in the reverse order of the init calls.

## Type Declarations

### Type aliases

To define a new type `NewType` as an alias for `ExistingType`,
do `type NewType = ExistingType`.<br/>
This is a special case of a [sum type](#sum-types) declaration.

### Enums

```v
enum Color as u8 {
	red
	green
	blue
}

mut color := Color.red
// V knows that `color` is a `Color`. No need to use `color = Color.green` here.
color = .green
println(color) // "green"
match color {
	.red { println('the color was red') }
	.green { println('the color was green') }
	.blue { println('the color was blue') }
}
```

The enum type can be any integer type, but can be omitted, if it is `int`: `enum Color {`.

Enum match must be exhaustive or have an `else` branch.
This ensures that if a new enum field is added, it's handled everywhere in the code.

Enum fields cannot re-use reserved keywords. However, reserved keywords may be escaped
with an @.

```v
enum Color {
	@none
	red
	green
	blue
}

color := Color.@none
println(color)
```

Integers may be assigned to enum fields.

```v
enum Grocery {
	apple
	orange = 5
	pear
}

g1 := int(Grocery.apple)
g2 := int(Grocery.orange)
g3 := int(Grocery.pear)
println('Grocery IDs: ${g1}, ${g2}, ${g3}')
```

Output: `Grocery IDs: 0, 5, 6`.

Operations are not allowed on enum variables; they must be explicitly cast to `int`.

Enums can have methods, just like structs.

```v
enum Cycle {
	one
	two
	three
}

fn (c Cycle) next() Cycle {
	match c {
		.one {
			return .two
		}
		.two {
			return .three
		}
		.three {
			return .one
		}
	}
}

mut c := Cycle.one
for _ in 0 .. 10 {
	println(c)
	c = c.next()
}
```

Output:

```
one
two
three
one
two
three
one
two
three
one
```

Enums can be created from string or integer value and converted into string

```v
enum Cycle {
	one
	two = 2
	three
}

// Create enum from value
println(Cycle.from(10) or { Cycle.three })
println(Cycle.from('two')!)

// Convert an enum value to a string
println(Cycle.one.str())
```

Output:

```
three
two
one
```

### Function Types

You can use type aliases for naming specific function signatures - for
example:

```v
type Filter = fn (string) string
```

This works like any other type - for example, a function can accept an
argument of a function type:

```v
type Filter = fn (string) string

fn filter(s string, f Filter) string {
	return f(s)
}
```

V has duck-typing, so functions don't need to declare compatibility with
a function type - they just have to be compatible:

```v
fn uppercase(s string) string {
	return s.to_upper()
}

// now `uppercase` can be used everywhere where Filter is expected
```

Compatible functions can also be explicitly cast to a function type:

```v oksyntax
my_filter := Filter(uppercase)
```

The cast here is purely informational - again, duck-typing means that the
resulting type is the same without an explicit cast:

```v oksyntax
my_filter := uppercase
```

You can pass the assigned function as an argument:

```v oksyntax
println(filter('Hello world', my_filter)) // prints `HELLO WORLD`
```

And you could of course have passed it directly as well, without using a
local variable:

```v oksyntax
println(filter('Hello world', uppercase))
```

And this works with anonymous functions as well:

```v oksyntax
println(filter('Hello world', fn (s string) string {
	return s.to_upper()
}))
```

You can see the complete
[example here](https://github.com/vlang/v/tree/master/examples/function_types.v).

### Interfaces

```v
// interface-example.1
struct Dog {
	breed string
}

fn (d Dog) speak() string {
	return 'woof'
}

struct Cat {
	breed string
}

fn (c Cat) speak() string {
	return 'meow'
}

// unlike Go, but like TypeScript, V's interfaces can define both fields and methods.
interface Speaker {
	breed string
	speak() string
}

fn main() {
	dog := Dog{'Leonberger'}
	cat := Cat{'Siamese'}

	mut arr := []Speaker{}
	arr << dog
	arr << cat
	for item in arr {
		println('a ${item.breed} says: ${item.speak()}')
	}
}
```

#### Implement an interface

A type implements an interface by implementing its methods and fields.
There is no explicit declaration of intent, no "implements" keyword.

An interface can have a `mut:` section. Implementing types will need
to have a `mut` receiver, for methods declared in the `mut:` section
of an interface.

```v
// interface-example.2
module main

interface Foo {
	write(string) string
}

// => the method signature of a type, implementing interface Foo should be:
// `fn (s Type) write(a string) string`

interface Bar {
mut:
	write(string) string
}

// => the method signature of a type, implementing interface Bar should be:
// `fn (mut s Type) write(a string) string`

struct MyStruct {}

// MyStruct implements the interface Foo, but *not* interface Bar
fn (s MyStruct) write(a string) string {
	return a
}

fn main() {
	s1 := MyStruct{}
	fn1(s1)
	// fn2(s1) -> compile error, since MyStruct does not implement Bar
}

fn fn1(s Foo) {
	println(s.write('Foo'))
}

// fn fn2(s Bar) { // does not match
//      println(s.write('Foo'))
// }
```

#### Casting an interface

We can test the underlying type of an interface using dynamic cast operators.
> [!NOTE]
> Dynamic cast converts variable `s` into a pointer inside the `if` statements in this example:

```v oksyntax
// interface-example.3 (continued from interface-example.1)
interface Something {}

fn announce(s Something) {
	if s is Dog {
		println('a ${s.breed} dog') // `s` is automatically cast to `Dog` (smart cast)
	} else if s is Cat {
		println('a cat speaks ${s.speak()}')
	} else {
		println('something else')
	}
}

fn main() {
	dog := Dog{'Leonberger'}
	cat := Cat{'Siamese'}
	announce(dog)
	announce(cat)
}
```

```v
// interface-example.4
interface IFoo {
	foo()
}

interface IBar {
	bar()
}

// implements only IFoo
struct SFoo {}

fn (sf SFoo) foo() {}

// implements both IFoo and IBar
struct SFooBar {}

fn (sfb SFooBar) foo() {}

fn (sfb SFooBar) bar() {
	dump('This implements IBar')
}

fn main() {
	mut arr := []IFoo{}
	arr << SFoo{}
	arr << SFooBar{}

	for a in arr {
		dump(a)
		// In order to execute instances that implements IBar.
		if a is IBar {
			a.bar()
		}
	}
}
```

For more information, see [Dynamic casts](#dynamic-casts).

#### Interface method definitions

Also unlike Go, an interface can have its own methods, similar to how
structs can have their methods. These 'interface methods' do not have
to be implemented, by structs which implement that interface.
They are just a convenient way to write `i.some_function()` instead of
`some_function(i)`, similar to how struct methods can be looked at, as
a convenience for writing `s.xyz()` instead of `xyz(s)`.

> [!NOTE]
> This feature is NOT a "default implementation" like in C#.

For example, if a struct `cat` is wrapped in an interface `a`, that has
implemented a method with the same name `speak`, as a method implemented by
the struct, and you do `a.speak()`, *only* the interface method is called:

```v
interface Adoptable {}

fn (a Adoptable) speak() string {
	return 'adopt me!'
}

struct Cat {}

fn (c Cat) speak() string {
	return 'meow!'
}

struct Dog {}

fn main() {
	cat := Cat{}
	assert dump(cat.speak()) == 'meow!'

	a := Adoptable(cat)
	assert dump(a.speak()) == 'adopt me!' // call Adoptable's `speak`
	if a is Cat {
		// Inside this `if` however, V knows that `a` is not just any
		// kind of Adoptable, but actually a Cat, so it will use the
		// Cat `speak`, NOT the Adoptable `speak`:
		dump(a.speak()) // meow!
	}

	b := Adoptable(Dog{})
	assert dump(b.speak()) == 'adopt me!' // call Adoptable's `speak`
	// if b is Dog {
	// 	dump(b.speak()) // error: unknown method or field: Dog.speak
	// }
}
```

#### Embedded interface

Interfaces support embedding, just like structs:

```v
pub interface Reader {
mut:
	read(mut buf []u8) ?int
}

pub interface Writer {
mut:
	write(buf []u8) ?int
}

// ReaderWriter embeds both Reader and Writer.
// The effect is the same as copy/pasting all of the
// Reader and all of the Writer methods/fields into
// ReaderWriter.
pub interface ReaderWriter {
	Reader
	Writer
}
```

### Sum types

A sum type instance can hold a value of several different types. Use the `type`
keyword to declare a sum type:

```v
struct Moon {}

struct Mars {}

struct Venus {}

type World = Mars | Moon | Venus

sum := World(Moon{})
assert sum.type_name() == 'Moon'
println(sum)
```

The built-in method `type_name` returns the name of the currently held
type.

With sum types you could build recursive structures and write concise but powerful code on them.

```v
// V's binary tree
struct Empty {}

struct Node {
	value f64
	left  Tree
	right Tree
}

type Tree = Empty | Node

// sum up all node values

fn sum(tree Tree) f64 {
	return match tree {
		Empty { 0 }
		Node { tree.value + sum(tree.left) + sum(tree.right) }
	}
}

fn main() {
	left := Node{0.2, Empty{}, Empty{}}
	right := Node{0.3, Empty{}, Node{0.4, Empty{}, Empty{}}}
	tree := Node{0.5, left, right}
	println(sum(tree)) // 0.2 + 0.3 + 0.4 + 0.5 = 1.4
}
```

#### Dynamic casts

To check whether a sum type instance holds a certain type, use `sum is Type`.
To cast a sum type to one of its variants you can use `sum as Type`:

```v
struct Moon {}

struct Mars {}

struct Venus {}

type World = Mars | Moon | Venus

fn (m Mars) dust_storm() bool {
	return true
}

fn main() {
	mut w := World(Moon{})
	assert w is Moon
	w = Mars{}
	// use `as` to access the Mars instance
	mars := w as Mars
	if mars.dust_storm() {
		println('bad weather!')
	}
}
```

`as` will panic if `w` doesn't hold a `Mars` instance.
A safer way is to use a smart cast.

#### Smart casting

```v oksyntax
if w is Mars {
	assert typeof(w).name == 'Mars'
	if w.dust_storm() {
		println('bad weather!')
	}
}
```

`w` has type `Mars` inside the body of the `if` statement. This is
known as *flow-sensitive typing*.
If `w` is a mutable identifier, it would be unsafe if the compiler smart casts it without a warning.
That's why you have to declare a `mut` before the `is` expression:

```v ignore
if mut w is Mars {
	assert typeof(w).name == 'Mars'
	if w.dust_storm() {
		println('bad weather!')
	}
}
```

Otherwise `w` would keep its original type.
> This works for both simple variables and complex expressions like `user.name`

#### Matching sum types

You can also use `match` to determine the variant:

```v
struct Moon {}

struct Mars {}

struct Venus {}

type World = Mars | Moon | Venus

fn open_parachutes(n int) {
	println(n)
}

fn land(w World) {
	match w {
		Moon {} // no atmosphere
		Mars {
			// light atmosphere
			open_parachutes(3)
		}
		Venus {
			// heavy atmosphere
			open_parachutes(1)
		}
	}
}
```

`match` must have a pattern for each variant or have an `else` branch.

```v ignore
struct Moon {}
struct Mars {}
struct Venus {}

type World = Moon | Mars | Venus

fn (m Moon) moon_walk() {}
fn (m Mars) shiver() {}
fn (v Venus) sweat() {}

fn pass_time(w World) {
    match w {
        // using the shadowed match variable, in this case `w` (smart cast)
        Moon { w.moon_walk() }
        Mars { w.shiver() }
        else {}
    }
}
```

### Option/Result types and error handling

Option types are for types which may represent `none`. Result types may
represent an error returned from a function.

`Option` types are declared by prepending `?` to the type name: `?Type`.
`Result` types use `!`: `!Type`.

```v
struct User {
	id   int
	name string
}

struct Repo {
	users []User
}

fn (r Repo) find_user_by_id(id int) !User {
	for user in r.users {
		if user.id == id {
			// V automatically wraps this into a result or option type
			return user
		}
	}
	return error('User ${id} not found')
}

// A version of the function using an option
fn (r Repo) find_user_by_id2(id int) ?User {
	for user in r.users {
		if user.id == id {
			return user
		}
	}
	return none
}

fn main() {
	repo := Repo{
		users: [User{1, 'Andrew'}, User{2, 'Bob'}, User{10, 'Charles'}]
	}
	user := repo.find_user_by_id(10) or { // Option/Result types must be handled by `or` blocks
		println(err)
		return
	}
	println(user.id) // "10"
	println(user.name) // "Charles"

	user2 := repo.find_user_by_id2(10) or { return }

	// To create an Option var directly:
	my_optional_int := ?int(none)
	my_optional_string := ?string(none)
	my_optional_user := ?User(none)
}
```

V used to combine `Option` and `Result` into one type, now they are separate.

The amount of work required to "upgrade" a function to an option/result function is minimal;
you have to add a `?` or `!` to the return type and return `none` or an error (respectively)
when something goes wrong.

This is the primary mechanism for error handling in V. They are still values, like in Go,
but the advantage is that errors can't be unhandled, and handling them is a lot less verbose.
Unlike other languages, V does not handle exceptions with `throw/try/catch` blocks.

`err` is defined inside an `or` block and is set to the string message passed
to the `error()` function.

```v oksyntax
user := repo.find_user_by_id(7) or {
	println(err) // "User 7 not found"
	return
}
```

#### Options/results when returning multiple values

Only one `Option` or `Result` is allowed to be returned from a function. It is 
possible to return multiple values and still signal an error.

```v
fn multireturn(v int) !(int, int) {
	if v < 0 {
		return error('must be positive')
	}
	return v, v * v
}
```

#### Handling options/results

There are four ways of handling an option/result. The first method is to
propagate the error:

```v
import net.http

fn f(url string) !string {
	resp := http.get(url)!
	return resp.body
}
```

`http.get` returns `!http.Response`. Because `!` follows the call, the
error will be propagated to the caller of `f`. When using `?` after a
function call producing an option, the enclosing function must return
an option as well. If error propagation is used in the `main()`
function it will `panic` instead, since the error cannot be propagated
any further.

The body of `f` is essentially a condensed version of:

```v ignore
    resp := http.get(url) or { return err }
    return resp.body
```

---
The second method is to break from execution early:

```v oksyntax
user := repo.find_user_by_id(7) or { return }
```

Here, you can either call `panic()` or `exit()`, which will stop the execution of the
entire program, or use a control flow statement (`return`, `break`, `continue`, etc)
to break from the current block.

> [!NOTE]
> `break` and `continue` can only be used inside a `for` loop.

V does not have a way to forcibly "unwrap" an option (as other languages do,
for instance Rust's `unwrap()` or Swift's `!`). To do this, use `or { panic(err) }` instead.

---
The third method is to provide a default value at the end of the `or` block.
In case of an error, that value would be assigned instead,
so it must have the same type as the content of the `Option` being handled.

```v
fn do_something(s string) !string {
	if s == 'foo' {
		return 'foo'
	}
	return error('invalid string')
}

a := do_something('foo') or { 'default' } // a will be 'foo'
b := do_something('bar') or { 'default' } // b will be 'default'
println(a)
println(b)
```

---
The fourth method is to use `if` unwrapping:

```v
import net.http

if resp := http.get('https://google.com') {
	println(resp.body) // resp is a http.Response, not an option
} else {
	println(err)
}
```

Above, `http.get` returns a `!http.Response`. `resp` is only in scope for the first
`if` branch. `err` is only in scope for the `else` branch.

### Custom error types

V gives you the ability to define custom error types through the `IError` interface.
The interface requires two methods: `msg() string` and `code() int`. Every type that
implements these methods can be used as an error.

When defining a custom error type it is recommended to embed the builtin `Error` default
implementation. This provides an empty default implementation for both required methods,
so you only have to implement what you really need, and may provide additional utility
functions in the future.

```v
struct PathError {
	Error
	path string
}

fn (err PathError) msg() string {
	return 'Failed to open path: ${err.path}'
}

fn try_open(path string) ! {
	// V automatically casts this to IError
	return PathError{
		path: path
	}
}

fn main() {
	try_open('/tmp') or { panic(err) }
}
```

### Generics

```v wip

struct Repo[T] {
    db DB
}

struct User {
	id   int
	name string
}

struct Post {
	id   int
	user_id int
	title string
	body string
}

fn new_repo[T](db DB) Repo[T] {
    return Repo[T]{db: db}
}

// This is a generic function. V will generate it for every type it's used with.
fn (r Repo[T]) find_by_id(id int) ?T {
    table_name := T.name // in this example getting the name of the type gives us the table name
    return r.db.query_one[T]('select * from ${table_name} where id = ?', id)
}

db := new_db()
users_repo := new_repo[User](db) // returns Repo[User]
posts_repo := new_repo[Post](db) // returns Repo[Post]
user := users_repo.find_by_id(1)? // find_by_id[User]
post := posts_repo.find_by_id(1)? // find_by_id[Post]
```

Currently generic function definitions must declare their type parameters, but in
future V will infer generic type parameters from single-letter type names in
runtime parameter types. This is why `find_by_id` can omit `[T]`, because the
receiver argument `r` uses a generic type `T`.

Another example:

```v
fn compare[T](a T, b T) int {
	if a < b {
		return -1
	}
	if a > b {
		return 1
	}
	return 0
}

// compare[int]
println(compare(1, 0)) // Outputs: 1
println(compare(1, 1)) //          0
println(compare(1, 2)) //         -1
// compare[string]
println(compare('1', '0')) // Outputs: 1
println(compare('1', '1')) //          0
println(compare('1', '2')) //         -1
// compare[f64]
println(compare(1.1, 1.0)) // Outputs: 1
println(compare(1.1, 1.1)) //          0
println(compare(1.1, 1.2)) //         -1
```

## Concurrency

### Spawning Concurrent Tasks

V's model of concurrency is going to be very similar to Go's.
For now, `spawn foo()` runs `foo()` concurrently in a different thread:

```v
import math

fn p(a f64, b f64) { // ordinary function without return value
	c := math.sqrt(a * a + b * b)
	println(c)
}

fn main() {
	spawn p(3, 4)
	// p will be run in parallel thread
	// It can also be written as follows
	// spawn fn (a f64, b f64) {
	// 	c := math.sqrt(a * a + b * b)
	// 	println(c)
	// }(3, 4)
}
```

> [!NOTE]
> Threads rely on the machine's CPU (number of cores/threads).
> Be aware that OS threads spawned with `spawn`
> have limitations in regard to concurrency,
> including resource overhead and scalability issues,
> and might affect performance in cases of high thread count.

There's also a `go` keyword. Right now `go foo()` will be automatically renamed via vfmt
to `spawn foo()`, and there will be a way to launch a coroutine with `go` (a lightweight
thread managed by the runtime).

Sometimes it is necessary to wait until a parallel thread has finished. This can
be done by assigning a *handle* to the started thread and calling the `wait()` method
to this handle later:

```v
import math

fn p(a f64, b f64) { // ordinary function without return value
	c := math.sqrt(a * a + b * b)
	println(c) // prints `5`
}

fn main() {
	h := spawn p(3, 4)
	// p() runs in parallel thread
	h.wait()
	// p() has definitely finished
}
```

This approach can also be used to get a return value from a function that is run in a
parallel thread. There is no need to modify the function itself to be able to call it
concurrently.

```v
import math { sqrt }

fn get_hypot(a f64, b f64) f64 { //       ordinary function returning a value
	c := sqrt(a * a + b * b)
	return c
}

fn main() {
	g := spawn get_hypot(54.06, 2.08) // spawn thread and get handle to it
	h1 := get_hypot(2.32, 16.74) //   do some other calculation here
	h2 := g.wait() //                 get result from spawned thread
	println('Results: ${h1}, ${h2}') //   prints `Results: 16.9, 54.1`
}
```

If there is a large number of tasks, it might be easier to manage them
using an array of threads.

```v
import time

fn task(id int, duration int) {
	println('task ${id} begin')
	time.sleep(duration * time.millisecond)
	println('task ${id} end')
}

fn main() {
	mut threads := []thread{}
	threads << spawn task(1, 500)
	threads << spawn task(2, 900)
	threads << spawn task(3, 100)
	threads.wait()
	println('done')
}

// Output:
// task 1 begin
// task 2 begin
// task 3 begin
// task 3 end
// task 1 end
// task 2 end
// done
```

Additionally for threads that return the same type, calling `wait()`
on the thread array will return all computed values.

```v
fn expensive_computing(i int) int {
	return i * i
}

fn main() {
	mut threads := []thread int{}
	for i in 1 .. 10 {
		threads << spawn expensive_computing(i)
	}
	// Join all tasks
	r := threads.wait()
	println('All jobs finished: ${r}')
}

// Output: All jobs finished: [1, 4, 9, 16, 25, 36, 49, 64, 81]
```

### Channels

Channels are the preferred way to communicate between threads. V's channels work basically like
those in Go. You can push objects into a channel on one end and pop objects from the other end.
Channels can be buffered or unbuffered and it is possible to `select` from multiple channels.

#### Syntax and Usage

Channels have the type `chan objtype`. An optional buffer length can be specified as the `cap` field
in the declaration:

```v
ch := chan int{} // unbuffered - "synchronous"
ch2 := chan f64{cap: 100} // buffer length 100
```

Channels do not have to be declared as `mut`. The buffer length is not part of the type but
a field of the individual channel object. Channels can be passed to threads like normal
variables:

```v
fn f(ch chan int) {
	// ...
}

fn main() {
	ch := chan int{}
	spawn f(ch)
	// ...
}
```

Objects can be pushed to channels using the arrow operator. The same operator can be used to
pop objects from the other end:

```v
// make buffered channels so pushing does not block (if there is room in the buffer)
ch := chan int{cap: 1}
ch2 := chan f64{cap: 1}
n := 5
// push
ch <- n
ch2 <- 7.3
mut y := f64(0.0)
m := <-ch // pop creating new variable
y = <-ch2 // pop into existing variable
```

A channel can be closed to indicate that no further objects can be pushed. Any attempt
to do so will then result in a runtime panic (with the exception of `select` and
`try_push()` - see below). Attempts to pop will return immediately if the
associated channel has been closed and the buffer is empty. This situation can be
handled using an `or {}` block (see [Handling options/results](#handling-optionsresults)).

```v wip
ch := chan int{}
ch2 := chan f64{}
// ...
ch.close()
// ...
m := <-ch or {
    println('channel has been closed')
}

// propagate error
y := <-ch2 ?
```

#### Channel Select

The `select` command allows monitoring several channels at the same time
without noticeable CPU load. It consists of a list of possible transfers and associated branches
of statements - similar to the [match](#match) command:

```v
import time

fn main() {
	ch := chan f64{}
	ch2 := chan f64{}
	ch3 := chan f64{}
	mut b := 0.0
	c := 1.0
	// ... setup spawn threads that will send on ch/ch2
	spawn fn (the_channel chan f64) {
		time.sleep(5 * time.millisecond)
		the_channel <- 1.0
	}(ch)
	spawn fn (the_channel chan f64) {
		time.sleep(1 * time.millisecond)
		the_channel <- 1.0
	}(ch2)
	spawn fn (the_channel chan f64) {
		_ := <-the_channel
	}(ch3)

	select {
		a := <-ch {
			// do something with `a`
			eprintln('> a: ${a}')
		}
		b = <-ch2 {
			// do something with predeclared variable `b`
			eprintln('> b: ${b}')
		}
		ch3 <- c {
			// do something if `c` was sent
			time.sleep(5 * time.millisecond)
			eprintln('> c: ${c} was send on channel ch3')
		}
		500 * time.millisecond {
			// do something if no channel has become ready within 0.5s
			eprintln('> more than 0.5s passed without a channel being ready')
		}
	}
	eprintln('> done')
}
```

The timeout branch is optional. If it is absent `select` waits for an unlimited amount of time.
It is also possible to proceed immediately if no channel is ready in the moment `select` is called
by adding an `else { ... }` branch. `else` and `<timeout>` are mutually exclusive.

The `select` command can be used as an *expression* of type `bool`
that becomes `false` if all channels are closed:

```v wip
if select {
    ch <- a {
        // ...
    }
} {
    // channel was open
} else {
    // channel is closed
}
```

#### Special Channel Features

For special purposes there are some builtin fields and methods:

```v
struct Abc {
	x int
}

a := 2.13
ch := chan f64{}
res := ch.try_push(a) // try to perform `ch <- a`
println(res)
l := ch.len // number of elements in queue
c := ch.cap // maximum queue length
is_closed := ch.closed // bool flag - has `ch` been closed
println(l)
println(c)
mut b := Abc{}
ch2 := chan Abc{}
res2 := ch2.try_pop(mut b) // try to perform `b = <-ch2`
```

The `try_push/pop()` methods will return immediately with one of the results
`.success`, `.not_ready` or `.closed` - dependent on whether the object has been transferred or
the reason why not.
Usage of these methods and fields in production is not recommended -
algorithms based on them are often subject to race conditions. Especially `.len` and
`.closed` should not be used to make decisions.
Use `or` branches, error propagation or `select` instead (see [Syntax and Usage](#syntax-and-usage)
and [Channel Select](#channel-select) above).

### Shared Objects

Data can be exchanged between a thread and the calling thread via a shared variable.
Such variables should be created as `shared` and passed to the thread as such, too.
The underlying `struct` contains a hidden *mutex* that allows locking concurrent access
using `rlock` for read-only and `lock` for read/write access.

```v
struct St {
mut:
	x int // data to be shared
}

fn (shared b St) g() {
	lock b {
		// read/modify/write b.x
	}
}

fn main() {
	shared a := St{
		x: 10
	}
	spawn a.g()
	// ...
	rlock a {
		// read a.x
	}
}
```

Shared variables must be structs, arrays or maps.

## JSON

Because of the ubiquitous nature of JSON, support for it is built directly into V.

V generates code for JSON encoding and decoding.
No runtime reflection is used. This results in much better performance.

### Decoding JSON

```v
import json

struct Foo {
	x int
}

struct User {
	// Adding a [required] attribute will make decoding fail, if that
	// field is not present in the input.
	// If a field is not [required], but is missing, it will be assumed
	// to have its default value, like 0 for numbers, or '' for strings,
	// and decoding will not fail.
	name string @[required]
	age  int
	// Use the `skip` attribute to skip certain fields
	foo Foo @[skip]
	// If the field name is different in JSON, it can be specified
	last_name string @[json: lastName]
}

data := '{ "name": "Frodo", "lastName": "Baggins", "age": 25 }'
user := json.decode(User, data) or {
	eprintln('Failed to decode json, error: ${err}')
	return
}
println(user.name)
println(user.last_name)
println(user.age)
// You can also decode JSON arrays:
sfoos := '[{"x":123},{"x":456}]'
foos := json.decode([]Foo, sfoos)!
println(foos[0].x)
println(foos[1].x)
```

The `json.decode` function takes two arguments:
the first is the type into which the JSON value should be decoded and
the second is a string containing the JSON data.

### Encoding JSON

```v
import json

struct User {
	name  string
	score i64
}

mut data := map[string]int{}
user := &User{
	name:  'Pierre'
	score: 1024
}

data['x'] = 42
data['y'] = 360

println(json.encode(data)) // {"x":42,"y":360}
println(json.encode(user)) // {"name":"Pierre","score":1024}
```

The json module also supports anonymous struct fields, which helps with complex JSON apis with lots
of levels.

## Testing

### Asserts

```v
fn foo(mut v []int) {
	v[0] = 1
}

mut v := [20]
foo(mut v)
assert v[0] < 4
```

An `assert` statement checks that its expression evaluates to `true`. If an assert fails,
the program will usually abort. Asserts should only be used to detect programming errors. When an
assert fails it is reported to *stderr*, and the values on each side of a comparison operator
(such as `<`, `==`) will be printed when possible. This is useful to easily find an
unexpected value. Assert statements can be used in any function, not just test ones,
which is handy when developing new functionality, to keep your invariants in check.

> [!NOTE]
> All `assert` statements are *removed*, when you compile your program with the `-prod` flag.

### Asserts with an extra message

This form of the `assert` statement, will print the extra message when it fails. Note that
you can use any string expression there - string literals, functions returning a string,
strings that interpolate variables, etc.

```v
fn test_assertion_with_extra_message_failure() {
	for i in 0 .. 100 {
		assert i * 2 - 45 < 75 + 10, 'assertion failed for i: ${i}'
	}
}
```

### Asserts that do not abort your program

When initially prototyping functionality and tests, it is sometimes desirable to
have asserts that do not stop the program, but just print their failures. That can
be achieved by tagging your assert containing functions with an `[assert_continues]`
tag, for example running this program:

```v
@[assert_continues]
fn abc(ii int) {
	assert ii == 2
}

for i in 0 .. 4 {
	abc(i)
}
```

... will produce this output:

```
assert_continues_example.v:3: FAIL: fn main.abc: assert ii == 2
   left value: ii = 0
   right value: 2
assert_continues_example.v:3: FAIL: fn main.abc: assert ii == 2
   left value: ii = 1
  right value: 2
assert_continues_example.v:3: FAIL: fn main.abc: assert ii == 2
   left value: ii = 3
  right value: 2
```

> [!NOTE]
> V also supports a command line flag `-assert continues`, which will change the
> behaviour of all asserts globally, as if you had tagged every function with `[assert_continues]`.

### Test files

```v
// hello.v
module main

fn hello() string {
	return 'Hello world'
}

fn main() {
	println(hello())
}
```

```v failcompile
// hello_test.v
module main

fn test_hello() {
	assert hello() == 'Hello world'
}
```

To run the test file above, use `v hello_test.v`. This will check that the function `hello` is
producing the correct output. V executes all test functions in the file.

> [!NOTE]
> All `_test.v` files (both external and internal ones), are compiled as *separate programs*.
> In other words, you may have as many `_test.v` files, and tests in them as you like, they will
> not affect the compilation of your other code in `.v` files normally at all, but only when you
> do explicitly `v file_test.v` or `v test .`.

* All test functions have to be inside a test file whose name ends in `_test.v`.
* Test function names must begin with `test_` to mark them for execution.
* Normal functions can also be defined in test files, and should be called manually. Other
  symbols can also be defined in test files e.g. types.
* There are two kinds of tests: external and internal.
* Internal tests must *declare* their module, just like all other .v
  files from the same module. Internal tests can even call private functions in
  the same module.
* External tests must *import* the modules which they test. They do not
  have access to the private functions/types of the modules. They can test only
  the external/public API that a module provides.

In the example above, `test_hello` is an internal test that can call
the private function `hello()` because `hello_test.v` has `module main`,
just like `hello.v`, i.e. both are part of the same module. Note also that
since `module main` is a regular module like the others, internal tests can
be used to test private functions in your main program .v files too.

You can also define these special test functions in a test file:

* `testsuite_begin` which will be run *before* all other test functions.
* `testsuite_end` which will be run *after* all other test functions.

If a test function has an error return type, any propagated errors will fail the test:

```v
import strconv

fn test_atoi() ! {
	assert strconv.atoi('1')! == 1
	assert strconv.atoi('one')! == 1 // test will fail
}
```

### Running tests

To run test functions in an individual test file, use `v foo_test.v`.

To test an entire module, use `v test mymodule`. You can also use `v test .` to test
everything inside your current folder (and subfolders). You can pass the `-stats`
option to see more details about the individual tests run.

You can put additional test data, including .v source files in a folder, named
`testdata`, right next to your _test.v files. V's test framework will *ignore*
such folders, while scanning for tests to run. This is useful, if you want to
put .v files with invalid V source code, or other tests, including known
failing ones, that should be run in a specific way/options by a parent _test.v
file.

> [!NOTE]
> The path to the V compiler, is available through @VEXE, so a _test.v
> file, can easily run *other* test files like this:

```v oksyntax
import os

fn test_subtest() {
	res := os.execute('${os.quoted_path(@VEXE)} other_test.v')
	assert res.exit_code == 1
	assert res.output.contains('other_test.v does not exist')
}
```

## Memory management

V avoids doing unnecessary allocations in the first place by using value types,
string buffers, promoting a simple abstraction-free code style.

There are 4 ways to manage memory in V.

The default is a minimal and a well performing tracing GC.

The second way is autofree, it can be enabled with `-autofree`. It takes care of most objects
(~90-100%): the compiler inserts necessary free calls automatically during compilation.
Remaining small percentage of objects is freed via GC. The developer doesn't need to change
anything in their code. "It just works", like in Python, Go, or Java, except there's no
heavy GC tracing everything or expensive RC for each object.

For developers willing to have more low level control, memory can be managed manually with
`-gc none`.

Arena allocation is available via v `-prealloc`.

### Control

You can take advantage of V's autofree engine and define a `free()` method on custom
data types:

```v
struct MyType {}

@[unsafe]
fn (data &MyType) free() {
	// ...
}
```

Just as the compiler frees C data types with C's `free()`, it will statically insert
`free()` calls for your data type at the end of each variable's lifetime.

Autofree can be enabled with an `-autofree` flag.

For developers willing to have more low level control, autofree can be disabled with
`-manualfree`, or by adding a `[manualfree]` on each function that wants to manage its
memory manually. (See [attributes](#attributes)).

> [!NOTE]
> Autofree is still WIP. Until it stabilises and becomes the default, please
> avoid using it. Right now allocations are handled by a minimal and well performing GC
> until V's autofree engine is production ready.

**Examples**

```v
import strings

fn draw_text(s string, x int, y int) {
	// ...
}

fn draw_scene() {
	// ...
	name1 := 'abc'
	name2 := 'def ghi'
	draw_text('hello ${name1}', 10, 10)
	draw_text('hello ${name2}', 100, 10)
	draw_text(strings.repeat(`X`, 10000), 10, 50)
	// ...
}
```

The strings don't escape `draw_text`, so they are cleaned up when
the function exits.

In fact, with the `-prealloc` flag, the first two calls won't result in any allocations at all.
These two strings are small, so V will use a preallocated buffer for them.

```v
struct User {
	name string
}

fn test() []int {
	number := 7 // stack variable
	user := User{} // struct allocated on stack
	numbers := [1, 2, 3] // array allocated on heap, will be freed as the function exits
	println(number)
	println(user)
	println(numbers)
	numbers2 := [4, 5, 6] // array that's being returned, won't be freed here
	return numbers2
}
```

### Stack and Heap

#### Stack and Heap Basics

Like with most other programming languages there are two locations where data can
be stored:

* The *stack* allows fast allocations with almost zero administrative overhead. The
  stack grows and shrinks with the function call depth &ndash; so every called
  function has its stack segment that remains valid until the function returns.
  No freeing is necessary, however, this also means that a reference to a stack
  object becomes invalid on function return. Furthermore stack space is
  limited (typically to a few Megabytes per thread).
* The *heap* is a large memory area (typically some Gigabytes) that is administrated
  by the operating system. Heap objects are allocated and freed by special function
  calls that delegate the administrative tasks to the OS. This means that they can
  remain valid across several function calls, however, the administration is
  expensive.

#### V's default approach

Due to performance considerations V tries to put objects on the stack if possible
but allocates them on the heap when obviously necessary. Example:

```v
struct MyStruct {
	n int
}

struct RefStruct {
	r &MyStruct
}

fn main() {
	q, w := f()
	println('q: ${q.r.n}, w: ${w.n}')
}

fn f() (RefStruct, &MyStruct) {
	a := MyStruct{
		n: 1
	}
	b := MyStruct{
		n: 2
	}
	c := MyStruct{
		n: 3
	}
	e := RefStruct{
		r: &b
	}
	x := a.n + c.n
	println('x: ${x}')
	return e, &c
}
```

Here `a` is stored on the stack since its address never leaves the function `f()`.
However a reference to `b` is part of `e` which is returned. Also a reference to
`c` is returned. For this reason `b` and `c` will be heap allocated.

Things become less obvious when a reference to an object is passed as a function argument:

```v
struct MyStruct {
mut:
	n int
}

fn main() {
	mut q := MyStruct{
		n: 7
	}
	w := MyStruct{
		n: 13
	}
	x := q.f(&w) // references of `q` and `w` are passed
	println('q: ${q}\nx: ${x}')
}

fn (mut a MyStruct) f(b &MyStruct) int {
	a.n += b.n
	x := a.n * b.n
	return x
}
```

Here the call `q.f(&w)` passes references to `q` and `w` because `a` is
`mut` and `b` is of type `&MyStruct` in `f()`'s declaration, so technically
these references are leaving `main()`. However the *lifetime* of these
references lies inside the scope of `main()` so `q` and `w` are allocated
on the stack.

#### Manual Control for Stack and Heap

In the last example the V compiler could put `q` and `w` on the stack
because it assumed that in the call `q.f(&w)` these references were only
used for reading and modifying the referred values &ndash; and not to pass the
references themselves somewhere else. This can be seen in a way that the
references to `q` and `w` are only *borrowed* to `f()`.

Things become different if `f()` is doing something with a reference itself:

```v
struct RefStruct {
mut:
	r &MyStruct
}

// see discussion below
@[heap]
struct MyStruct {
	n int
}

fn main() {
	mut m := MyStruct{}
	mut r := RefStruct{
		r: &m
	}
	r.g()
	println('r: ${r}')
}

fn (mut r RefStruct) g() {
	s := MyStruct{
		n: 7
	}
	r.f(&s) // reference to `s` inside `r` is passed back to `main() `
}

fn (mut r RefStruct) f(s &MyStruct) {
	r.r = s // would trigger error without `[heap]`
}
```

Here `f()` looks quite innocent but is doing nasty things &ndash; it inserts a
reference to `s` into `r`. The problem with this is that `s` lives only as long
as `g()` is running but `r` is used in `main()` after that. For this reason
the compiler would complain about the assignment in `f()` because `s` *"might
refer to an object stored on stack"*. The assumption made in `g()` that the call
`r.f(&s)` would only borrow the reference to `s` is wrong.

A solution to this dilemma is the `[heap]` [attribute](#attributes) at the declaration of
`struct MyStruct`. It instructs the compiler to *always* allocate `MyStruct`-objects
on the heap. This way the reference to `s` remains valid even after `g()` returns.
The compiler takes into consideration that `MyStruct` objects are always heap
allocated when checking `f()` and allows assigning the reference to `s` to the
`r.r` field.

There is a pattern often seen in other programming languages:

```v failcompile
fn (mut a MyStruct) f() &MyStruct {
	// do something with a
	return &a // would return address of borrowed object
}
```

Here `f()` is passed a reference `a` as receiver that is passed back to the caller and returned
as result at the same time. The intention behind such a declaration is method chaining like
`y = x.f().g()`. However, the problem with this approach is that a second reference
to `a` is created &ndash; so it is not only borrowed and `MyStruct` has to be
declared as `[heap]`.

In V the better approach is:

```v
struct MyStruct {
mut:
	n int
}

fn (mut a MyStruct) f() {
	// do something with `a`
}

fn (mut a MyStruct) g() {
	// do something else with `a`
}

fn main() {
	x := MyStruct{} // stack allocated
	mut y := x
	y.f()
	y.g()
	// instead of `mut y := x.f().g()
}
```

This way the `[heap]` attribute can be avoided &ndash; resulting in better performance.

However, stack space is very limited as mentioned above. For this reason the `[heap]`
attribute might be suitable for very large structures even if not required by use cases
like those mentioned above.

There is an alternative way to manually control allocation on a case to case basis. This
approach is not recommended but shown here for the sake of completeness:

```v
struct MyStruct {
	n int
}

struct RefStruct {
mut:
	r &MyStruct
}

// simple function - just to overwrite stack segment previously used by `g()`

fn use_stack() {
	x := 7.5
	y := 3.25
	z := x + y
	println('${x} ${y} ${z}')
}

fn main() {
	mut m := MyStruct{}
	mut r := RefStruct{
		r: &m
	}
	r.g()
	use_stack() // to erase invalid stack contents
	println('r: ${r}')
}

fn (mut r RefStruct) g() {
	s := &MyStruct{ // `s` explicitly refers to a heap object
		n: 7
	}
	// change `&MyStruct` -> `MyStruct` above and `r.f(s)` -> `r.f(&s)` below
	// to see data in stack segment being overwritten
	r.f(s)
}

fn (mut r RefStruct) f(s &MyStruct) {
	r.r = unsafe { s } // override compiler check
}
```

Here the compiler check is suppressed by the `unsafe` block. To make `s` be heap
allocated even without `[heap]` attribute the `struct` literal is prefixed with
an ampersand: `&MyStruct{...}`.

This last step would not be required by the compiler but without it the reference
inside `r` becomes invalid (the memory area pointed to will be overwritten by
`use_stack()`) and the program might crash (or at least produce an unpredictable
final output). That's why this approach is *unsafe* and should be avoided!

## ORM

(This is still in an alpha state)

V has a built-in ORM (object-relational mapping) which supports SQLite, MySQL and Postgres,
but soon it will support MS SQL and Oracle.

V's ORM provides a number of benefits:

- One syntax for all SQL dialects. (Migrating between databases becomes much easier.)
- Queries are constructed using V's syntax. (There's no need to learn another syntax.)
- Safety. (All queries are automatically sanitised to prevent SQL injection.)
- Compile time checks. (This prevents typos which can only be caught during runtime.)
- Readability and simplicity. (You don't need to manually parse the results of a query and
  then manually construct objects from the parsed results.)

```v
import db.sqlite

// sets a custom table name. Default is struct name (case-sensitive)
@[table: 'customers']
struct Customer {
	id        int @[primary; sql: serial] // a field named `id` of integer type must be the first field
	name      string
	nr_orders int
	country   ?string
}

db := sqlite.connect('customers.db')!

// You can create tables from your struct declarations. For example the next query will issue SQL similar to this:
// CREATE TABLE IF NOT EXISTS `Customer` (
//      `id` INTEGER PRIMARY KEY,
//      `name` TEXT NOT NULL,
//      `nr_orders` INTEGER NOT NULL,
//      `country` TEXT
// )
sql db {
	create table Customer
}!

// insert a new customer:
new_customer := Customer{
	name:      'Bob'
	country:   'uk'
	nr_orders: 10
}
sql db {
	insert new_customer into Customer
}!

us_customer := Customer{
	name:      'Martin'
	country:   'us'
	nr_orders: 5
}
sql db {
	insert us_customer into Customer
}!

none_country_customer := Customer{
	name:      'Dennis'
	country:   none
	nr_orders: 2
}
sql db {
	insert none_country_customer into Customer
}!

// update a customer:
sql db {
	update Customer set nr_orders = nr_orders + 1 where name == 'Bob'
}!

// select count(*) from customers
nr_customers := sql db {
	select count from Customer
}!
println('number of all customers: ${nr_customers}')

// V's syntax can be used to build queries:
uk_customers := sql db {
	select from Customer where country == 'uk' && nr_orders > 0
}!
println('We found a total of ${uk_customers.len} customers matching the query.')
for c in uk_customers {
	println('customer: ${c.id}, ${c.name}, ${c.country}, ${c.nr_orders}')
}

none_country_customers := sql db {
	select from Customer where country is none
}!
println('We found a total of ${none_country_customers.len} customers, with no country set.')
for c in none_country_customers {
	println('customer: ${c.id}, ${c.name}, ${c.country}, ${c.nr_orders}')
}

// delete a customer
sql db {
	delete from Customer where name == 'Bob'
}!
```

For more examples and the docs, see [vlib/orm](https://github.com/vlang/v/tree/master/vlib/orm).
