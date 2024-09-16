
# Advanced Topics

## Attributes

V has several attributes that modify the behavior of functions and structs.

An attribute is a compiler instruction specified inside `[]` right before a
function/struct/enum declaration and applies only to the following declaration.

```v
// @[flag] enables Enum types to be used as bitfields

@[flag]
enum BitField {
	read
	write
	other
}

fn main() {
	assert 1 == int(BitField.read)
	assert 2 == int(BitField.write)
	mut bf := BitField.read
	assert bf.has(.read | .other) // test if *at least one* of the flags is set
	assert !bf.all(.read | .other) // test if *all* of the flags are set
	bf.set(.write | .other)
	assert bf.has(.read | .write | .other)
	assert bf.all(.read | .write | .other)
	bf.toggle(.other)
	assert bf == BitField.read | .write
	assert bf.all(.read | .write)
	assert !bf.has(.other)
	empty := BitField.zero()
	assert empty.is_empty()
	assert !empty.has(.read)
	assert !empty.has(.write)
	assert !empty.has(.other)
	mut full := empty
	full.set_all()
	assert int(full) == 7 // 0x01 + 0x02 + 0x04
	assert full == .read | .write | .other
	mut v := full
	v.clear(.read | .other)
	assert v == .write
	v.clear_all()
	assert v == empty
	assert BitField.read == BitField.from('read')!
	assert BitField.other == BitField.from('other')!
	assert BitField.write == BitField.from(2)!
	assert BitField.zero() == BitField.from('')!
}
```

Struct field deprecations:

```v oksyntax
module abc

// Note that only *direct* accesses to Xyz.d in *other modules*, will produce deprecation notices/warnings:
pub struct Xyz {
pub mut:
	a int
	d int @[deprecated: 'use Xyz.a instead'; deprecated_after: '2999-03-01']
	// the tags above, will produce a notice, since the deprecation date is in the far future
}
```

Function/method deprecations:

```v
// Calling this function will result in a deprecation warning

@[deprecated]
fn old_function() {
}

// It can also display a custom deprecation message

@[deprecated: 'use new_function() instead']
fn legacy_function() {}

// You can also specify a date, after which the function will be
// considered deprecated. Before that date, calls to the function
// will be compiler notices - you will see them, but the compilation
// is not affected. After that date, calls will become warnings,
// so ordinary compiling will still work, but compiling with -prod
// will not (all warnings are treated like errors with -prod).
// 6 months after the deprecation date, calls will be hard
// compiler errors.

@[deprecated: 'use new_function2() instead']
@[deprecated_after: '2021-05-27']
fn legacy_function2() {}
```

```v globals
// This function's calls will be inlined.
@[inline]
fn inlined_function() {
}

// This function's calls will NOT be inlined.
@[noinline]
fn function() {
}

// This function will NOT return to its callers.
// Such functions can be used at the end of or blocks,
// just like exit/1 or panic/1. Such functions can not
// have return types, and should end either in for{}, or
// by calling other `[noreturn]` functions.
@[noreturn]
fn forever() {
	for {}
}

// The following struct must be allocated on the heap. Therefore, it can only be used as a
// reference (`&Window`) or inside another reference (`&OuterStruct{ Window{...} }`).
// See section "Stack and Heap"
@[heap]
struct Window {
}

// Calls to following function must be in unsafe{} blocks.
// Note that the code in the body of `risky_business()` will still be
// checked, unless you also wrap it in `unsafe {}` blocks.
// This is useful, when you want to have an `[unsafe]` function that
// has checks before/after a certain unsafe operation, that will still
// benefit from V's safety features.
@[unsafe]
fn risky_business() {
	// code that will be checked, perhaps checking pre conditions
	unsafe {
		// code that *will not be* checked, like pointer arithmetic,
		// accessing union fields, calling other `[unsafe]` fns, etc...
		// Usually, it is a good idea to try minimizing code wrapped
		// in unsafe{} as much as possible.
		// See also [Memory-unsafe code](#memory-unsafe-code)
	}
	// code that will be checked, perhaps checking post conditions and/or
	// keeping invariants
}

// V's autofree engine will not take care of memory management in this function.
// You will have the responsibility to free memory manually yourself in it.
// Note: it is NOT related to the garbage collector. It will only make the
// -autofree mechanism, ignore the body of that function.
@[manualfree]
fn custom_allocations() {
}

// The memory pointed to by the pointer arguments of this function will not be
// freed by the garbage collector (if in use) before the function returns
// For C interop only.
@[keep_args_alive]
fn C.my_external_function(voidptr, int, voidptr) int

// A @[weak] tag tells the C compiler, that the next declaration will be weak, i.e. when linking,
// if there is another declaration of a symbol with the same name (a 'strong' one), it should be
// used instead, *without linker errors about duplicate symbols*.
// For C interop only.

@[weak]
__global abc = u64(1)

// Tell V, that the following global was defined on the C side,
// thus V will not initialise it, but will just give you access to it.
// For C interop only.

@[c_extern]
__global my_instance C.my_struct
struct C.my_struct {
	a int
	b f64
}

// Tell V that the following struct is defined with `typedef struct` in C.
// For C interop only.
@[typedef]
pub struct C.Foo {}

// Used to add a custom calling convention to a function, available calling convention: stdcall, fastcall and cdecl.
// This list also applies for type aliases (see below).
// For C interop only.
@[callconv: 'stdcall']
fn C.DefWindowProc(hwnd int, msg int, lparam int, wparam int)

// Used to add a custom calling convention to a function type aliases.
// For C interop only.

@[callconv: 'fastcall']
type FastFn = fn (int) bool

// Windows only:
// Without this attribute all graphical apps will have the following behavior on Windows:
// If run from a console or terminal; keep the terminal open so all (e)println statements can be viewed.
// If run from e.g. Explorer, by double-click; app is opened, but no terminal is opened, and no
// (e)println output can be seen.
// Use it to force-open a terminal to view output in, even if the app is started from Explorer.
// Valid before main() only.
@[console]
fn main() {
}
```

## Conditional compilation

The goal of this feature, is to tell V to *not compile* a function, and all its calls, in the final
executable, if a provided custom flag is not passed.

V will still type check the function and all its calls, *even* if they will not be present in the
final executable, due to the passed -d flags.

In order to see it in action, run the following example with `v run example.v` once,
and then a second time with `v -d trace_logs example.v`:
```v
@[if trace_logs ?]
fn elog(s string) {
	eprintln(s)
}

fn main() {
	elog('some expression: ${2 + 2}') // such calls will not be done *at all*, if `-d trace_logs` is not passed
	println('hi')
	elog('finish')
}
```

Conditional compilation, based on custom flags, can also be used to produce slightly different
executables, which share the majority of the same code, but where some of the logic, is needed
only some of the time, for example a network server/client program can be written like so:
```v ignore
fn act_as_client() { ... }
fn act_as_server() { ... }
fn main() {
	$if as_client ? {
		act_as_client()
	}
	$if as_server ? {
		act_as_server()
	}
}
```
To generate a `client.exe` executable do: `v -d as_client -o client.exe .`
To generate a `server.exe` executable do: `v -d as_server -o server.exe .`

### Compile time pseudo variables

V also gives your code access to a set of pseudo string variables,
that are substituted at compile time:

- `@FN` => replaced with the name of the current V function.
- `@METHOD` => replaced with ReceiverType.MethodName.
- `@MOD` => replaced with the name of the current V module.
- `@STRUCT` => replaced with the name of the current V struct.
- `@FILE` => replaced with the absolute path of the V source file.
- `@LINE` => replaced with the V line number where it appears (as a string).
- `@FILE_LINE` => like `@FILE:@LINE`, but the file part is a relative path.
- `@LOCATION` => file, line and name of the current type + method; suitable for logging.
- `@COLUMN` => replaced with the column where it appears (as a string).
- `@VEXE` => replaced with the path to the V compiler.
- `@VEXEROOT`  => will be substituted with the *folder*,
  where the V executable is (as a string).
- `@VHASH`  => replaced with the shortened commit hash of the V compiler (as a string).
- `@VCURRENTHASH` => Similar to `@VHASH`, but changes when the compiler is
  recompiled on a different commit (after local modifications, or after
  using git bisect etc).
- `@VMOD_FILE` => replaced with the contents of the nearest v.mod file (as a string).
- `@VMODHASH` => is replaced by the shortened commit hash, derived from the .git directory
  next to the nearest v.mod file (as a string).
- `@VMODROOT` => will be substituted with the *folder*,
  where the nearest v.mod file is (as a string).

That allows you to do the following example, useful while debugging/logging/tracing your code:

```v
eprintln(@LOCATION)
```

Another example, is if you want to embed the version/name from v.mod *inside* your executable:

```v ignore
import v.vmod
vm := vmod.decode( @VMOD_FILE ) or { panic(err) }
eprintln('${vm.name} ${vm.version}\n ${vm.description}')
```

A program that prints its own source code (a quine):
```v
print($embed_file(@FILE).to_string())
```

> [!NOTE]
> you can have arbitrary source code in the file, without problems, since the full file
> will be embedded into the executable, produced by compiling it. Also note that printing
> is done with `print` and not `println`, to not add another new line, missing in the
> source code.


### Compile time reflection

`$` is used as a prefix for compile time (also referred to as 'comptime') operations.

Having built-in JSON support is nice, but V also allows you to create efficient
serializers for any data format. V has compile time `if` and `for` constructs:

#### <h4 id="comptime-fields">.fields</h4>

You can iterate over struct fields using `.fields`, it also works with generic types
(e.g. `T.fields`) and generic arguments (e.g. `param.fields` where `fn gen[T](param T) {`).

```v
struct User {
	name string
	age  int
}

fn main() {
	$for field in User.fields {
		$if field.typ is string {
			println('${field.name} is of type string')
		}
	}
}

// Output:
// name is of type string
```

#### <h4 id="comptime-values">.values</h4>

You can read [Enum](#enums) values and their attributes.

```v
enum Color {
	red   @[RED]  // first attribute
	blue  @[BLUE] // second attribute
}

fn main() {
	$for e in Color.values {
		println(e.name)
		println(e.attrs)
	}
}

// Output:
// red
// ['RED']
// blue
// ['BLUE']
```

#### <h4 id="comptime-attrs">.attributes</h4>

You can read [Struct](#structs) attributes.

```v
@[COLOR]
struct Foo {
	a int
}

fn main() {
	$for e in Foo.attributes {
		println(e)
	}
}

// Output:
// StructAttribute{
//    name: 'COLOR'
//    has_arg: false
//    arg: ''
//    kind: plain
// }
```

#### <h4 id="comptime-variants">.variants</h4>

You can read variant types from [Sum type](#sum-types).

```v
type MySum = int | string

fn main() {
	$for v in MySum.variants {
		$if v.typ is int {
			println('has int type')
		} $else $if v.typ is string {
			println('has string type')
		}
	}
}

// Output:
// has int type
// has string type
```

#### <h4 id="comptime-methods">.methods</h4>

You can retrieve information about struct methods.

```v
struct Foo {
}

fn (f Foo) test() int {
	return 123
}

fn (f Foo) test2() string {
	return 'foo'
}

fn main() {
	foo := Foo{}
	$for m in Foo.methods {
		$if m.return_type is int {
			print('${m.name} returns int: ')
			println(foo.$method())
		} $else $if m.return_type is string {
			print('${m.name} returns string: ')
			println(foo.$method())
		}
	}
}

// Output:
// test returns int: 123
// test2 returns string: foo
```

See [`examples/compiletime/reflection.v`](/examples/compiletime/reflection.v)
for a more complete example.

### Compile time code

#### `$if` condition

```v
fn main() {
	// Support for multiple conditions in one branch
	$if ios || android {
		println('Running on a mobile device!')
	}
	$if linux && x64 {
		println('64-bit Linux.')
	}
	// Usage as expression
	os := $if windows { 'Windows' } $else { 'UNIX' }
	println('Using ${os}')
	// $else-$if branches
	$if tinyc {
		println('tinyc')
	} $else $if clang {
		println('clang')
	} $else $if gcc {
		println('gcc')
	} $else {
		println('different compiler')
	}
	$if test {
		println('testing')
	}
	// v -cg ...
	$if debug {
		println('debugging')
	}
	// v -prod ...
	$if prod {
		println('production build')
	}
	// v -d option ...
	$if option ? {
		println('custom option')
	}
}
```

If you want an `if` to be evaluated at compile time it must be prefixed with a `$` sign.
Right now it can be used to detect an OS, compiler, platform or compilation options.
`$if debug` is a special option like `$if windows` or `$if x32`, it's enabled if the program
is compiled with `v -g` or `v -cg`.
If you're using a custom ifdef, then you do need `$if option ? {}` and compile with`v -d option`.
Full list of builtin options:

| OS                             | Compilers        | Platforms                     | Other                                         |
|--------------------------------|------------------|-------------------------------|-----------------------------------------------|
| `windows`, `linux`, `macos`    | `gcc`, `tinyc`   | `amd64`, `arm64`, `aarch64`   | `debug`, `prod`, `test`                       |
| `darwin`, `ios`, `bsd`         | `clang`, `mingw` | `i386`, `arm32`               | `js`, `glibc`, `prealloc`                     |
| `freebsd`, `openbsd`, `netbsd` | `msvc`           | `rv64`, `rv32`                | `no_bounds_checking`, `freestanding`          |
| `android`, `mach`, `dragonfly` | `cplusplus`      | `x64`, `x32`                  | `no_segfault_handler`, `no_backtrace`         |
| `gnu`, `hpux`, `haiku`, `qnx`  |                  | `little_endian`, `big_endian` | `no_main`, `fast_math`, `apk`, `threads`      |
| `solaris`, `termux`            |                  |                               | `js_node`, `js_browser`, `js_freestanding`    |
| `serenity`, `vinix`, `plan9`   |                  |                               | `interpreter`, `es5`, `profile`, `wasm32`     |
|                                |                  |                               | `wasm32_emscripten`, `wasm32_wasi`            |
|                                |                  |                               | `native`, `autofree`                          |

#### `$embed_file`

```v ignore
import os
fn main() {
	embedded_file := $embed_file('v.png')
	os.write_file('exported.png', embedded_file.to_string())!
}
```

V can embed arbitrary files into the executable with the `$embed_file(<path>)`
compile time call. Paths can be absolute or relative to the source file.

Note that by default, using `$embed_file(file)`, will always embed the whole content
of the file, but you can modify that behaviour by passing: `-d embed_only_metadata`
when compiling your program. In that case, the file will not be embedded. Instead,
it will be loaded *the first time* your program calls `embedded_file.data()` at runtime,
making it easier to change in external editor programs, without needing to recompile
your program.

Embedding a file inside your executable, will increase its size, but
it will make it more self contained and thus easier to distribute.
When that happens (the default), `embedded_file.data()` will cause *no IO*,
and it will always return the same data.

`$embed_file` supports compression of the embedded file when compiling with `-prod`.
Currently only one compression type is supported: `zlib`.

```v ignore
import os
fn main() {
	embedded_file := $embed_file('x.css', .zlib) // compressed using zlib
	os.write_file('exported.css', embedded_file.to_string())!
}
```

Note: compressing binary assets like png or zip files, usually will not gain you much,
and in some cases may even take more space in the final executable, since they are
already compressed.

`$embed_file` returns
[EmbedFileData](https://modules.vlang.io/v.embed_file.html#EmbedFileData)
which could be used to obtain the file contents as `string` or `[]u8`.

#### `$tmpl` for embedding and parsing V template files

V has a simple template language for text and html templates, and they can easily
be embedded via `$tmpl('path/to/template.txt')`:

```v ignore
fn build() string {
	name := 'Peter'
	age := 25
	numbers := [1, 2, 3]
	return $tmpl('1.txt')
}

fn main() {
	println(build())
}
```

1.txt:

```
name: @name

age: @age

numbers: @numbers

@for number in numbers
  @number
@end
```

output:

```
name: Peter

age: 25

numbers: [1, 2, 3]

1
2
3
```

See more [details](https://github.com/vlang/v/blob/master/vlib/v/TEMPLATES.md)

#### `$env`

```v
module main

fn main() {
	compile_time_env := $env('ENV_VAR')
	println(compile_time_env)
}
```

V can bring in values at compile time from environment variables.
`$env('ENV_VAR')` can also be used in top-level `#flag` and `#include` statements:
`#flag linux -I $env('JAVA_HOME')/include`.

#### `$d`

V can bring in values at compile time from `-d ident=value` flag defines, passed on
the command line to the compiler. You can also pass `-d ident`, which will have the
same meaning as passing `-d ident=true`.

To get the value in your code, use: `$d('ident', default)`, where `default`
can be `false` for booleans, `0` or `123` for i64 numbers, `0.0` or `113.0`
for f64 numbers, `'a string'` for strings.

When a flag is not provided via the command line, `$d()` will return the `default`
value provided as the *second* argument.

```v
module main

const my_i64 = $d('my_i64', 1024)

fn main() {
	compile_time_value := $d('my_string', 'V')
	println(compile_time_value)
	println(my_i64)
}
```

Running the above with `v run .` will output:
```
V
1024
```

Running the above with `v -d my_i64=4096 -d my_string="V rocks" run .` will output:
```
V rocks
4096
```

Here is an example of how to use the default values, which have to be *pure* literals:
```v
fn main() {
	val_str := $d('id_str', 'value') // can be changed by providing `-d id_str="my id"`
	val_f64 := $d('id_f64', 42.0) // can be changed by providing `-d id_f64=84.0`
	val_i64 := $d('id_i64', 56) // can be changed by providing `-d id_i64=123`
	val_bool := $d('id_bool', false) // can be changed by providing `-d id_bool=true`
	val_char := $d('id_char', `f`) // can be changed by providing `-d id_char=v`
	println(val_str)
	println(val_f64)
	println(val_i64)
	println(val_bool)
	println(rune(val_char))
}
```

`$d('ident','value')` can also be used in top-level statements like `#flag` and `#include`:
`#flag linux -I $d('my_include','/usr')/include`. The default value for `$d` when used in these
statements should be literal `string`s.

`$d('ident', false)` can also be used inside `$if $d('ident', false) {` statements,
granting you the ability to selectively turn on/off certain sections of code, at compile
time, without modifying your source code, or keeping different versions of it.

#### `$compile_error` and `$compile_warn`

These two comptime functions are very useful for displaying custom errors/warnings during
compile time.

Both receive as their only argument a string literal that contains the message to display:

```v failcompile nofmt
// x.v
module main

$if linux {
    $compile_error('Linux is not supported')
}

fn main() {
}

$ v run x.v
x.v:4:5: error: Linux is not supported
    2 |
    3 | $if linux {
    4 |     $compile_error('Linux is not supported')
      |     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    5 | }
    6 |
```

### Compile time types

Compile time types group multiple types into a general higher-level type. This is useful in
functions with generic parameters, where the input type must have a specific property, for example
the `.len` attribute in arrays.

V supports the following compile time types:

- `$alias` => matches [Type aliases](#type-aliases).
- `$array` => matches [Arrays](#arrays) and [Fixed Size Arrays](#fixed-size-arrays).
- `$array_dynamic` => matches [Arrays](#arrays), but not [Fixed Size Arrays](#fixed-size-arrays).
- `$array_fixed` => matches [Fixed Size Arrays](#fixed-size-arrays), but not [Arrays](#arrays)
- `$enum` => matches [Enums](#enums).
- `$float` => matches `f32`, `f64` and float literals.
- `$function` => matches [Function Types](#function-types).
- `$int` => matches `int`, `i8`, `i16`, `i32`, `i64`, `u8`, `u16`, `u32`, `u64`, `isize`, `usize`
  and integer literals.
- `$interface` => matches [Interfaces](#interfaces).
- `$map` => matches [Maps](#maps).
- `$option` => matches [Option Types](#optionresult-types-and-error-handling).
- `$struct` => matches [Structs](#structs).
- `$sumtype` => matches [Sum Types](#sum-types).
- `$string` => matches [Strings](#strings).

### Environment specific files

If a file has an environment-specific suffix, it will only be compiled for that environment.

- `.js.v` => will be used only by the JS backend. These files can contain JS. code.
- `.c.v` => will be used only by the C backend. These files can contain C. code.
- `.native.v` => will be used only by V's native backend.
- `_nix.c.v` => will be used only on Unix systems (non Windows).
- `_${os}.c.v` => will be used only on the specific `os` system.
  For example, `_windows.c.v` will be used only when compiling on Windows, or with `-os windows`.
- `_default.c.v` => will be used only if there is NOT a more specific platform file.
  For example, if you have both `file_linux.c.v` and `file_default.c.v`,
  and you are compiling for linux, then only `file_linux.c.v` will be used,
  and `file_default.c.v` will be ignored.

Here is a more complete example:
main.v:

```v ignore
module main
fn main() { println(message) }
```

main_default.c.v:

```v ignore
module main
const message = 'Hello world'
```

main_linux.c.v:

```v ignore
module main
const message = 'Hello linux'
```

main_windows.c.v:

```v ignore
module main
const message = 'Hello windows'
```

With the example above:

- when you compile for windows, you will get 'Hello windows'
- when you compile for linux, you will get 'Hello linux'
- when you compile for any other platform, you will get the
  non specific 'Hello world' message.

- `_d_customflag.v` => will be used *only* if you pass `-d customflag` to V.
  That corresponds to `$if customflag ? {}`, but for a whole file, not just a
  single block. `customflag` should be a snake_case identifier, it can not
  contain arbitrary characters (only lower case latin letters + numbers + `_`).
  > **Note**
  >
  > A combinatorial `_d_customflag_linux.c.v` postfix will not work.
  > If you do need a custom flag file, that has platform dependent code, use the
  > postfix `_d_customflag.v`, and then use platform dependent compile time
  > conditional blocks inside it, i.e. `$if linux {}` etc.

- `_notd_customflag.v` => similar to _d_customflag.v, but will be used
  *only* if you do NOT pass `-d customflag` to V.

See also [Cross Compilation](#cross-compilation).

## Debugger

To use the native *V debugger*, add the `$dbg` statement to your source, where you
want the debugger to be invoked.

```v
fn main() {
	a := 1
	$dbg;
}
```

Running this V code, you will get the debugger REPL break when the execution
reaches the `$dbg` statement.

```
$ v run example.v
Break on [main] main in example.v:3
example.v:3 vdbg>
```

At this point, execution is halted, and the debugger is now available.

To see the available commands, type
?, h or help. (Completion for commands works - Non-Windows only)

```
example.v:3 vdbg> ?
vdbg commands:
  anon?                 check if the current context is anon
  bt                    prints a backtrace
  c, continue           continue debugging
  generic?              check if the current context is generic
  heap                  show heap memory usage
  h, help, ?            show this help
  l, list [lines]       show some lines from current break (default: 3)
  mem, memory           show memory usage
  method?               check if the current context is a method
  m, mod                show current module name
  p, print <var>        prints an variable
  q, quit               exits debugging session in the code
  scope                 show the vars in the current scope
  u, unwatch <var>      unwatches a variable
  w, watch <var>        watches a variable
```

Lets try the `scope` command, to inspect the current scope context.

```
example.v:3 vdbg> scope
a = 1 (int)
```

Cool! We have the variable name, its value and its type name.

What about printing only a variable, not the whole scope?

Just type `p a`.

To watch a variable by its name, use:

`w a` (where `a` is the variable name)

To stop watching the variable (`unwatch` it), use `u a`.

Lets see more one example:

```
fn main() {
	for i := 0; i < 4; i++ {
		$dbg
	}
}
```

Running again, we'll get:
`Break on [main] main in example.v:3`

If we want to read the source code context, we can use the `l` or `list` command.

```
example.v:3 vdbg> l
0001  fn main() {
0002    for i := 0; i < 4; i++ {
0003>           $dbg
0004    }
0005  }
```

The default is read 3 lines before and 3 lines after, but you can
pass a parameter to the command to read more lines, like `l 5`.

Now, lets watch the variable changing on this loop.

```
example.v:3 vdbg> w i
i = 0 (int)
```

To continue to the next breakpoint, type `c` or `continue` command.

```
example.v:3 vdbg> c
Break on [main] main in example.v:3
i = 1 (int)
```

`i` and it's value is automatically printed, because it is in the watch list.

To repeat the last command issued, in this case the `c` command,
just hit the *enter* key.

```
example.v:3 vdbg>
Break on [main] main in example.v:3
i = 2 (int)
example.v:3 vdbg>
Break on [main] main in example.v:3
i = 3 (int)
example.v:3 vdbg>
```

You can also see memory usage with `mem` or `memory` command, and
check if the current context is an anon function (`anon?`), a method (`method?`)
or a generic method (`generic?`) and clear the terminal window (`clear`).

## Call stack

You can also show the current call stack with `v.debug`.

To enable this feature, add the `-d callstack` switch when building or running
your code:

```v
import v.debug

fn test(i int) {
	if i > 9 {
		debug.dump_callstack()
	}
}

fn do_something() {
	for i := 0; i <= 10; i++ {
		test(i)
	}
}

fn main() {
	do_something()
}
```

```
$ v -d callstack run example.v
Backtrace:
--------------------------------------------------
example.v:16   | > main.main
example.v:11   |  > main.do_something
example.v:5    |   > main.test
--------------------------------------------------
```

## Trace

Another feature of `v.debug` is the possibility to add hook functions
before and after each function call.

To enable this feature, add the `-d trace` switch when building or running
your code:

```v
import v.debug

fn main() {
	hook1 := debug.add_before_call(fn (fn_name string) {
		println('> before ${fn_name}')
	})
	hook2 := debug.add_after_call(fn (fn_name string) {
		println('> after ${fn_name}')
	})
	anon := fn () {
		println('call')
	}
	anon()

	// optionally you can remove the hooks:
	debug.remove_before_call(hook1)
	debug.remove_after_call(hook2)
	anon()
}
```

```
$ v -d trace run example.v
> before anon
call
> after anon
call
```

## Memory-unsafe code

Sometimes for efficiency you may want to write low-level code that can potentially
corrupt memory or be vulnerable to security exploits. V supports writing such code,
but not by default.

V requires that any potentially memory-unsafe operations are marked intentionally.
Marking them also indicates to anyone reading the code that there could be
memory-safety violations if there was a mistake.

Examples of potentially memory-unsafe operations are:

* Pointer arithmetic
* Pointer indexing
* Conversion to pointer from an incompatible type
* Calling certain C functions, e.g. `free`, `strlen` and `strncmp`.

To mark potentially memory-unsafe operations, enclose them in an `unsafe` block:

```v wip
// allocate 2 uninitialized bytes & return a reference to them
mut p := unsafe { malloc(2) }
p[0] = `h` // Error: pointer indexing is only allowed in `unsafe` blocks
unsafe {
    p[0] = `h` // OK
    p[1] = `i`
}
p++ // Error: pointer arithmetic is only allowed in `unsafe` blocks
unsafe {
    p++ // OK
}
assert *p == `i`
```

Best practice is to avoid putting memory-safe expressions inside an `unsafe` block,
so that the reason for using `unsafe` is as clear as possible. Generally any code
you think is memory-safe should not be inside an `unsafe` block, so the compiler
can verify it.

If you suspect your program does violate memory-safety, you have a head start on
finding the cause: look at the `unsafe` blocks (and how they interact with
surrounding code).

> [!NOTE]
> This is work in progress.

## Structs with reference fields

Structs with references require explicitly setting the initial value to a
reference value unless the struct already defines its own initial value.

Zero-value references, or nil pointers, will **NOT** be supported in the future,
for now data structures such as Linked Lists or Binary Trees that rely on reference
fields that can use the value `0`, understanding that it is unsafe, and that it can
cause a panic.

```v
struct Node {
	a &Node
	b &Node = unsafe { nil } // Auto-initialized to nil, use with caution!
}

// Reference fields must be initialized unless an initial value is declared.
// Zero (0) is OK but use with caution, it's a nil pointer.
foo := Node{
	a: 0
}
bar := Node{
	a: &foo
}
baz := Node{
	a: 0
	b: 0
}
qux := Node{
	a: &foo
	b: &bar
}
println(baz)
println(qux)
```

## sizeof and __offsetof

* `sizeof(Type)` gives the size of a type in bytes.
* `__offsetof(Struct, field_name)` gives the offset in bytes of a struct field.

```v
struct Foo {
	a int
	b int
}

assert sizeof(Foo) == 8
assert __offsetof(Foo, a) == 0
assert __offsetof(Foo, b) == 4
```

## Limited operator overloading

Operator overloading defines the behavior of certain binary operators for certain types.

```v
struct Vec {
	x int
	y int
}

fn (a Vec) str() string {
	return '{${a.x}, ${a.y}}'
}

fn (a Vec) + (b Vec) Vec {
	return Vec{a.x + b.x, a.y + b.y}
}

fn (a Vec) - (b Vec) Vec {
	return Vec{a.x - b.x, a.y - b.y}
}

fn main() {
	a := Vec{2, 3}
	b := Vec{4, 5}
	mut c := Vec{1, 2}

	println(a + b) // "{6, 8}"
	println(a - b) // "{-2, -2}"
	c += a
	//^^ autogenerated from + overload
	println(c) // "{3, 5}"
}
```

> Operator overloading goes against V's philosophy of simplicity and predictability.
> But since scientific and graphical applications are among V's domains,
> operator overloading is an important feature to have in order to improve readability:
>
> `a.add(b).add(c.mul(d))` is a lot less readable than `a + b + c * d`.

Operator overloading is possible for the following binary operators: `+, -, *, /, %, <, ==`.

### Implicitly generated overloads

- `==` is automatically generated by the compiler, but can be overridden.

- `!=`, `>`, `<=` and `>=` are automatically generated when `==` and `<` are defined.
  They cannot be explicitly overridden.
- Assignment operators (`*=`, `+=`, `/=`, etc) are automatically generated when the corresponding
  operators are defined and the operands are of the same type.
  They cannot be explicitly overridden.

### Restriction

To improve safety and maintainability, operator overloading is limited.

#### Type restrictions

- When overriding `<` and `==`, the return type must be strictly `bool`.
- Both arguments must have the same type (just like with all operators in V).
- Overloaded operators have to return the same type as the argument
  (the exceptions are `<` and `==`).

#### Other restrictions

- Arguments cannot be changed inside overloads.
- Calling other functions inside operator functions is not allowed (**planned**).

## Performance tuning

When compiled with `-prod`, V's generated C code usually performs well. However, in specialized
scenarios, additional compiler flags and attributes can further optimize the executable for
performance, memory usage, or size.

> [!NOTE]
> These are *rarely* needed, and should not be used unless you
> *profile your code*, and then see that there are significant benefits for them.
> To cite GCC's documentation: "Programmers are notoriously bad at predicting
> how their programs actually perform".

| Tuning Operation         | Benefits                        | Drawbacks                                         |
|--------------------------|---------------------------------|---------------------------------------------------|
| `@[inline]`              | Performance                     | Increased executable size                         |
| `@[direct_array_access]` | Performance                     | Safety risks                                      |
| `@[packed]`              | Memory usage                    | Potential performance loss                        |
| `@[minify]`              | Performance, Memory usage       | May break binary serialization/reflection         |
| `_likely_/_unlikely_`    | Performance                     | Risk of negative performance impact               |
| `-skip-unused`           | Performance, Compile time, Size | Potential instability                             |
| `-fast-math`             | Performance                     | Risk of incorrect mathematical operations results |
| `-d no_segfault_handler` | Compile time, Size              | Loss of segfault trace                            |
| `-cflags -march=native`  | Performance                     | Risk of reduced CPU compatibility                 |
| `-compress`              | Size                            | Harder to debug, extra dependency `upx`           |
| `PGO`                    | Performance, Size               | Usage complexity                                  |

### Tuning operations details

#### `@[inline]`

You can tag functions with `@[inline]`, so the C compiler will try to inline them, which in some
cases, may be beneficial for performance, but may impact the size of your executable.

**When to Use**

- Functions that are called frequently in performance-critical loops.

**When to Avoid**

- Large functions, as it might cause code bloat and actually decrease performance.
- Large functions in `if` expressions - may have negative impact on instructions cache.

#### `@[direct_array_access]`

In functions tagged with `@[direct_array_access]` the compiler will translate array operations
directly into C array operations - omitting bounds checking. This may save a lot of time in a
function that iterates over an array but at the cost of making the function unsafe - unless the
boundaries will be checked by the user.

**When to Use**

- In tight loops that access array elements, where bounds have been manually verified or you are
sure that the access index will be valid.

**When to Avoid**

- Everywhere else.

#### `@[packed]`

The `@[packed]` attribute can be applied to a structure to create an unaligned memory layout,
which decreases the overall memory footprint of the structure. Using the `@[packed]` attribute
may negatively impact performance or even be prohibited on certain CPU architectures.

**When to Use**

- When memory usage is more critical than performance, e.g., in embedded systems.

**When to Avoid**

- On CPU architectures that do not support unaligned memory access or when high-speed memory access
is needed.

#### `@[aligned]`

The `@[aligned]` attribute can be applied to a structure or union to specify a minimum alignment
(in bytes) for variables of that type. Using the `@[aligned]` attribute you can only *increase*
the default alignment. Use `@[packed]` if you want to *decrease* it. The alignment of any struct
or union, should be at least a perfect multiple of the lowest common multiple of the alignments of
all of the members of the struct or union.

Example:
```v
// Each u16 in the `data` field below, takes 2 bytes, and we have 3 of them = 6 bytes.
// The smallest power of 2, bigger than 6 is 8, i.e. with `@[aligned]`, the alignment
// for the entire struct U16s, will be 8:
@[aligned]
struct U16s {
	data [3]u16
}
```
**When to Use**

- Only if the instances of your types, will be used in performance critical sections, or with
specialised machine instructions, that do require a specific alignment to work.

**When to Avoid**

- On CPU architectures, that do not support unaligned memory access. If you are not working on
performance critical algorithms, you do not really need it, since the proper minimum alignment
is CPU specific, and the compiler already usually will choose a good default for you.

> [!NOTE]
> You can leave out the alignment factor, i.e. use just `@[aligned]`, in which case the compiler
> will align a type to the maximum useful alignment for the target machine you are compiling for,
> i.e. the alignment will be the largest alignment which is ever used for any data type on the
> target machine. Doing this can often make copy operations more efficient, because the compiler
> can choose whatever instructions copy the biggest chunks of memory, when performing copies to or
> from the variables which have types that you have aligned this way.

See also ["What Every Programmer Should Know About Memory", by Ulrich Drepper](https://people.freebsd.org/~lstewart/articles/cpumemory.pdf) .

#### `@[minify]`

The `@[minify]` attribute can be added to a struct, allowing the compiler to reorder the fields in
a way that minimizes internal gaps while maintaining alignment. Using the `@[minify]` attribute may
cause issues with binary serialization or reflection. Be mindful of these potential side effects
when using this attribute.

**When to Use**

- When you want to minimize memory usage and you're not using binary serialization or reflection.

**When to Avoid**

- When using binary serialization or reflection, as it may cause unexpected behavior.

#### `_likely_/_unlikely_`

`if _likely_(bool expression) {` - hints to the C compiler, that the passed boolean expression is
very likely to be true, so it can generate assembly code, with less chance of branch misprediction.
In the JS backend, that does nothing.

`if _unlikely_(bool expression) {` is similar to `_likely_(x)`, but it hints that the boolean
expression is highly improbable. In the JS backend, that does nothing.

**When to Use**

- In conditional statements where one branch is clearly more frequently executed than the other.

**When to Avoid**

- When the prediction can be wrong, as it might cause a performance penalty due to branch
misprediction.

#### `-skip-unused`

This flag tells the V compiler to omit code that is not needed in the final executable to run your
program correctly. This will remove unneeded `const` arrays allocations and unused functions
from the code in the generated executable.

This flag will be on by default in the future when its implementation will be stabilized and all
severe bugs will be found.

**When to Use**

- For production builds where you want to reduce the executable size and improve runtime
performance.

**When to Avoid**

- Where it doesn't work for you.

#### `-fast-math`

This flag enables optimizations that disregard strict compliance with the IEEE standard for
floating-point arithmetic. While this could lead to faster code, it may produce incorrect or
less accurate mathematical results.

The full specter of math operations that `-fast-math` affects can be found
[here](https://clang.llvm.org/docs/UsersManual.html#cmdoption-ffast-math).

**When to Use**

- In applications where performance is more critical than precision, like certain graphics
rendering tasks.

**When to Avoid**

- In applications requiring strict mathematical accuracy, such as scientific simulations or
financial calculations.

#### `-d no_segfault_handler`

Using this flag omits the segfault handler, reducing the executable size and potentially improving
compile time. However, in the case of a segmentation fault, the output will not contain stack trace
information, making debugging more challenging.

**When to Use**

- In small, well-tested utilities where a stack trace is not essential for debugging.

**When to Avoid**

- In large-scale, complex applications where robust debugging is required.

#### `-cflags -march=native`

This flag directs the C compiler to generate instructions optimized for the host CPU. This can
improve performance but will produce an executable incompatible with other/older CPUs.

**When to Use**

- When the software is intended to run only on the build machine or in a controlled environment
with identical hardware.

**When to Avoid**

- When distributing the software to users with potentially older CPUs.

#### `-compress`

This flag executes `upx` to compress the resultant executable, reducing its size by around 50%-70%.
The executable will be uncompressed at runtime, so it will take a bit more time to start.
It will also take extra RAM initially, as the compressed version of the app will be loaded into
memory, and then expanded to another chunk of memory.
Debugging such an application can be a bit harder, if you do not account for it.
Some antivirus programs also use heuristics, that trigger more often for compressed applications.

**When to Use**

- For really tiny environments, where the size of the executable on the file system,
or when deploying is important (docker containers, rescue disks etc).

**When to Avoid**

- When you need to debug the application
- When the app's startup time is extremely important (where 1-2ms can be meaningful for you)
- When you can not afford to allocate more memory during application startup
- When you are deploying an app to users with antivirus software that could misidentify your
app as malicious, just because it decompresses its code at runtime.

#### PGO (Profile-Guided Optimization)

PGO allows the compiler to optimize code based on its behavior during sample runs. This can improve
performance and reduce the size of the output executable, but it adds complexity to the build
process.

**When to Use**

- For performance-critical applications where the added build complexity is justifiable.

**When to Avoid**

- For small, short-lived, or rapidly-changing projects where the added build complexity isn't
justified.

**PGO with Clang**

This is an example bash script you can use to optimize your CLI V program without user interactions.
In most cases, you will need to change this script to make it suitable for your particular program.

```bash
#!/usr/bin/env bash

# Get the full path to the current directory
CUR_DIR=$(pwd)

# Remove existing PGO data
rm -f *.profraw
rm -f default.profdata

# Initial build with PGO instrumentation
v -cc clang -skip-unused -prod -cflags -fprofile-generate -o pgo_gen .

# Run the instrumented executable 10 times
for i in {1..10}; do
    ./pgo_gen
done

# Merge the collected data
llvm-profdata merge -o default.profdata *.profraw

# Compile the optimized version using the PGO data
v -cc clang -skip-unused -prod -cflags "-fprofile-use=${CUR_DIR}/default.profdata" -o optimized_program .

# Remove PGO data and instrumented executable
rm *.profraw
rm pgo_gen
```

## Atomics

V has no special support for atomics, yet, nevertheless it's possible to treat variables as atomics
by [calling C](#v-and-c) functions from V. The standard C11 atomic functions like `atomic_store()`
are usually defined with the help of macros and C compiler magic to provide a kind of
*overloaded C functions*.
Since V does not support overloading functions by intention there are wrapper functions defined in
C headers named `atomic.h` that are part of the V compiler infrastructure.

There are dedicated wrappers for all unsigned integer types and for pointers.
(`u8` is not fully supported on Windows) &ndash; the function names include the type name
as suffix. e.g. `C.atomic_load_ptr()` or `C.atomic_fetch_add_u64()`.

To use these functions the C header for the used OS has to be included and the functions
that are intended to be used have to be declared. Example:

```v globals
$if windows {
	#include "@VEXEROOT/thirdparty/stdatomic/win/atomic.h"
} $else {
	#include "@VEXEROOT/thirdparty/stdatomic/nix/atomic.h"
}

// declare functions we want to use - V does not parse the C header
fn C.atomic_store_u32(&u32, u32)
fn C.atomic_load_u32(&u32) u32
fn C.atomic_compare_exchange_weak_u32(&u32, &u32, u32) bool
fn C.atomic_compare_exchange_strong_u32(&u32, &u32, u32) bool

const num_iterations = 10000000

// see section "Global Variables" below
__global (
	atom u32 // ordinary variable but used as atomic
)

fn change() int {
	mut races_won_by_change := 0
	for {
		mut cmp := u32(17) // addressable value to compare with and to store the found value
		// atomic version of `if atom == 17 { atom = 23 races_won_by_change++ } else { cmp = atom }`
		if C.atomic_compare_exchange_strong_u32(&atom, &cmp, 23) {
			races_won_by_change++
		} else {
			if cmp == 31 {
				break
			}
			cmp = 17 // re-assign because overwritten with value of atom
		}
	}
	return races_won_by_change
}

fn main() {
	C.atomic_store_u32(&atom, 17)
	t := spawn change()
	mut races_won_by_main := 0
	mut cmp17 := u32(17)
	mut cmp23 := u32(23)
	for i in 0 .. num_iterations {
		// atomic version of `if atom == 17 { atom = 23 races_won_by_main++ }`
		if C.atomic_compare_exchange_strong_u32(&atom, &cmp17, 23) {
			races_won_by_main++
		} else {
			cmp17 = 17
		}
		desir := if i == num_iterations - 1 { u32(31) } else { u32(17) }
		// atomic version of `for atom != 23 {} atom = desir`
		for !C.atomic_compare_exchange_weak_u32(&atom, &cmp23, desir) {
			cmp23 = 23
		}
	}
	races_won_by_change := t.wait()
	atom_new := C.atomic_load_u32(&atom)
	println('atom: ${atom_new}, #exchanges: ${races_won_by_main + races_won_by_change}')
	// prints `atom: 31, #exchanges: 10000000`)
	println('races won by\n- `main()`: ${races_won_by_main}\n- `change()`: ${races_won_by_change}')
}
```

In this example both `main()` and the spawned thread `change()` try to replace a value of `17`
in the global `atom` with a value of `23`. The replacement in the opposite direction is
done exactly 10000000 times. The last replacement will be with `31` which makes the spawned
thread finish.

It is not predictable how many replacements occur in which thread, but the sum will always
be 10000000. (With the non-atomic commands from the comments the value will be higher or the program
will hang &ndash; dependent on the compiler optimization used.)

## Global Variables

By default V does not allow global variables. However, in low level applications they have their
place so their usage can be enabled with the compiler flag `-enable-globals`.
Declarations of global variables must be surrounded with a `__global ( ... )`
specification &ndash; as in the example [above](#atomics).

An initializer for global variables must be explicitly converted to the
desired target type. If no initializer is given a default initialization is done.
Some objects like semaphores and mutexes require an explicit initialization *in place*, i.e.
not with a value returned from a function call but with a method call by reference.
A separate `init()` function can be used for this purpose &ndash; it will be called before `main()`:

```v globals
import sync

__global (
	sem   sync.Semaphore // needs initialization in `init()`
	mtx   sync.RwMutex // needs initialization in `init()`
	f1    = f64(34.0625) // explicily initialized
	shmap shared map[string]f64 // initialized as empty `shared` map
	f2    f64 // initialized to `0.0`
)

fn init() {
	sem.init(0)
	mtx.init()
}
```

Be aware that in multi threaded applications the access to global variables is subject
to race conditions. There are several approaches to deal with these:

- use `shared` types for the variable declarations and use `lock` blocks for access.
  This is most appropriate for larger objects like structs, arrays or maps.
- handle primitive data types as "atomics" using special C-functions (see [above](#atomics)).
- use explicit synchronization primitives like mutexes to control access. The compiler
  cannot really help in this case, so you have to know what you are doing.
- don't care &ndash; this approach is possible but makes only sense if the exact values
  of global variables do not really matter. An example can be found in the `rand` module
  where global variables are used to generate (non cryptographic) pseudo random numbers.
  In this case data races lead to random numbers in different threads becoming somewhat
  correlated, which is acceptable considering the performance penalty that using
  synchronization primitives would represent.

## Cross compilation

To cross compile your project simply run

```shell
v -os windows .
```

or

```shell
v -os linux .
```

> [!NOTE]
> Cross-compiling a windows binary on a linux machine requires the GNU C compiler for
> MinGW-w64 (targeting Win64) to first be installed.

For Ubuntu/Debian based distributions:

```shell
sudo apt install gcc-mingw-w64-x86-64
```

For Arch based distributions:

```shell
sudo pacman -S mingw-w64-gcc
```

(Cross compiling for macOS is temporarily not possible.)

If you don't have any C dependencies, that's all you need to do. This works even
when compiling GUI apps using the `ui` module or graphical apps using `gg`.

You will need to install Clang, LLD linker, and download a zip file with
libraries and include files for Windows and Linux. V will provide you with a link.

## Debugging

### C Backend binaries (Default)

To debug issues in the generated binary (flag: `-b c`), you can pass these flags:

- `-g` - produces a less optimized executable with more debug information in it.
  V will enforce line numbers from the .v files in the stacktraces, that the
  executable will produce on panic. It is usually better to pass -g, unless
  you are writing low level code, in which case use the next option `-cg`.
- `-cg` - produces a less optimized executable with more debug information in it.
  The executable will use C source line numbers in this case. It is frequently
  used in combination with `-keepc`, so that you can inspect the generated
  C program in case of panic, or so that your debugger (`gdb`, `lldb` etc.)
  can show you the generated C source code.
- `-showcc` - prints the C command that is used to build the program.
- `-show-c-output` - prints the output, that your C compiler produced
  while compiling your program.
- `-keepc` - do not delete the generated C source code file after a successful
  compilation. Also keep using the same file path, so it is more stable,
  and easier to keep opened in an editor/IDE.

For best debugging experience if you are writing a low level wrapper for an existing
C library, you can pass several of these flags at the same time:
`v -keepc -cg -showcc yourprogram.v`, then just run your debugger (gdb/lldb) or IDE
on the produced executable `yourprogram`.

If you just want to inspect the generated C code,
without further compilation, you can also use the `-o` flag (e.g. `-o file.c`).
This will make V produce the `file.c` then stop.

If you want to see the generated C source code for *just* a single C function,
for example `main`, you can use: `-printfn main -o file.c`.

To debug the V executable itself you need to compile from src with `./v -g -o v cmd/v`.

You can debug tests with for example `v -g -keepc prog_test.v`. The `-keepc` flag is needed,
so that the executable is not deleted, after it was created and ran.

To see a detailed list of all flags that V supports,
use `v help`, `v help build` and `v help build-c`.

**Commandline Debugging**

1. compile your binary with debugging info `v -g hello.v`
2. debug with [lldb](https://lldb.llvm.org) or [GDB](https://www.gnu.org/software/gdb/)
   e.g. `lldb hello`

[Troubleshooting (debugging) executables created with V in GDB](https://github.com/vlang/v/wiki/Troubleshooting-(debugging)-executables-created-with-V-in-GDB)

**Visual debugging Setup:**

* [Visual Studio Code](vscode.md)

### Native Backend binaries

Currently there is no debugging support for binaries, created by the
native backend (flag: `-b native`).

### Javascript Backend

To debug the generated Javascript output you can activate source maps:
`v -b js -sourcemap hello.v -o hello.js`

For all supported options check the latest help:
`v help build-js`

## V and C

### Calling C from V

V currently does not have a parser for C code. That means that even
though it allows you to `#include` existing C header and source files,
it will not know anything about the declarations in them. The `#include`
statement will only appear in the generated C code, to be used by the
C compiler backend itself.

**Example of #include**
```v oksyntax
#include <stdio.h>
```
After this statement, V will *not* know anything about the functions and
structs declared in `stdio.h`, but if you try to compile the .v file,
it will add the include in the generated C code, so that if that header file
is missing, you will get a C error (you will not in this specific case, if you
have a proper C compiler setup, since `<stdio.h>` is part of the
standard C library).

To overcome that limitation (that V does not have a C parser), V needs you to
redeclare the C functions and structs, on the V side, in your `.c.v` files.
Note that such redeclarations only need to have enough details about the
functions/structs that you want to use.
Note also that they *do not have* to be complete, unlike the ones in the .h files.


**C. struct redeclarations**
For example, if a struct has 3 fields on the C side, but you want to only
refer to 1 of them, you can declare it like this:

**Example of C struct redeclaration**
```v oksyntax
struct C.NameOfTheStruct {
	a_field int
}
```
Another feature, that is very frequently needed for C interoperability,
is the `@[typedef]` attribute. It is used for marking `C.` structs,
that are defined with `typedef struct SomeName { ..... } TypeName;` in the C headers.

For that case, you will have to write something like this in your .c.v file:
```v oksyntax
@[typedef]
pub struct C.TypeName {
}
```
Note that the name of the `C.` struct in V, is the one *after* the `struct SomeName {...}`.

**C. function redeclarations**
The situation is similar for `C.` functions. If you are going to call just 1 function in a
library, but its .h header declares dozens of them, you will only need to declare that single
function, for example:

**Example of C function redeclaration**
```v oksyntax
fn C.name_of_the_C_function(param1 int, const_param2 &char, param3 f32) f64
```
... and then later, you will be able to call the same way you would V function:
```v oksyntax
f := C.name_of_the_C_function(123, c'here is some C style string', 1.23)
dump(f)
```

**Example of using a C function from stdio, by redeclaring it on the V side**
```v
#include <stdio.h>

// int dprintf(int fd, const char *format, ...)
fn C.dprintf(fd int, const_format &char, ...voidptr) int

value := 12345
x := C.dprintf(0, c'Hello world, value: %d\n', value)
dump(x)
```

If your C backend compiler is properly setup, you should see something like this, when you try
to run it:
```console
#0 10:42:32 /v/examples> v run a.v
Hello world, value: 12345
[a.v:8] x: 26
#0 10:42:33 /v/examples>
```

Note, that the C function redeclarations look very simillar to the V ones, with some differences:
1) They lack a body (they are defined on the C side) .
2) Their names start with `C.` .
3) Their names can have capital letters (unlike V ones, that are required to use snake_case) .

Note also the second parameter `const char *format`, which was redeclared as `const_format &char` .
The `const_` prefix in that redeclaration may seem arbitrary, but it is important, if you want
to compile your code with `-cstrict` or thirdparty C static analysis tools. V currently does not
have another way to express that this parameter is a const (this will probably change in V 1.0).

For some C functions, that use variadics (`...`) as parameters, V supports a special syntax for
the parameters - `...voidptr`, that is not available for ordinary V functions (V's variadics are
*required* to have the same exact type). Usually those are functions of the printf/scanf family
i.e for `printf`, `fprintf`, `scanf`, `sscanf`, etc, and other formatting/parsing/logging
functions.

**Example**

```v
#flag freebsd -I/usr/local/include -L/usr/local/lib
#flag -lsqlite3
#include "sqlite3.h"
// See also the example from https://www.sqlite.org/quickstart.html
pub struct C.sqlite3 {
}

pub struct C.sqlite3_stmt {
}

type FnSqlite3Callback = fn (voidptr, int, &&char, &&char) int

fn C.sqlite3_open(&char, &&C.sqlite3) int

fn C.sqlite3_close(&C.sqlite3) int

fn C.sqlite3_column_int(stmt &C.sqlite3_stmt, n int) int

// ... you can also just define the type of parameter and leave out the C. prefix

fn C.sqlite3_prepare_v2(&C.sqlite3, &char, int, &&C.sqlite3_stmt, &&char) int

fn C.sqlite3_step(&C.sqlite3_stmt)

fn C.sqlite3_finalize(&C.sqlite3_stmt)

fn C.sqlite3_exec(db &C.sqlite3, sql &char, cb FnSqlite3Callback, cb_arg voidptr, emsg &&char) int

fn C.sqlite3_free(voidptr)

fn my_callback(arg voidptr, howmany int, cvalues &&char, cnames &&char) int {
	unsafe {
		for i in 0 .. howmany {
			print('| ${cstring_to_vstring(cnames[i])}: ${cstring_to_vstring(cvalues[i]):20} ')
		}
	}
	println('|')
	return 0
}

fn main() {
	db := &C.sqlite3(unsafe { nil }) // this means `sqlite3* db = 0`
	// passing a string literal to a C function call results in a C string, not a V string
	C.sqlite3_open(c'users.db', &db)
	// C.sqlite3_open(db_path.str, &db)
	query := 'select count(*) from users'
	stmt := &C.sqlite3_stmt(unsafe { nil })
	// Note: You can also use the `.str` field of a V string,
	// to get its C style zero terminated representation
	C.sqlite3_prepare_v2(db, &char(query.str), -1, &stmt, 0)
	C.sqlite3_step(stmt)
	nr_users := C.sqlite3_column_int(stmt, 0)
	C.sqlite3_finalize(stmt)
	println('There are ${nr_users} users in the database.')

	error_msg := &char(0)
	query_all_users := 'select * from users'
	rc := C.sqlite3_exec(db, &char(query_all_users.str), my_callback, voidptr(7), &error_msg)
	if rc != C.SQLITE_OK {
		eprintln(unsafe { cstring_to_vstring(error_msg) })
		C.sqlite3_free(error_msg)
	}
	C.sqlite3_close(db)
}
```

### Calling V from C

Since V can compile to C, calling V code from C is very easy, once you know how.

Use `v -o file.c your_file.v` to generate a C file, corresponding to the V code.

More details in [call_v_from_c example](../examples/call_v_from_c).

### Passing C compilation flags

Add `#flag` directives to the top of your V files to provide C compilation flags like:

- `-I` for adding C include files search paths
- `-l` for adding C library names that you want to get linked
- `-L` for adding C library files search paths
- `-D` for setting compile time variables

You can (optionally) use different flags for different targets.
Currently the `linux`, `darwin` , `freebsd`, and `windows` flags are supported.

> [!NOTE]
> Each flag must go on its own line (for now)

```v oksyntax
#flag linux -lsdl2
#flag linux -Ivig
#flag linux -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS=1
#flag linux -DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1
#flag linux -DIMGUI_IMPL_API=
```

In the console build command, you can use:

* `-cc` to change the default C backend compiler.
* `-cflags` to pass custom flags to the backend C compiler (passed before other C options).
* `-ldflags` to pass custom flags to the backend C linker (passed after every other C option).
* For example: `-cc gcc-9 -cflags -fsanitize=thread`.

You can define a `VFLAGS` environment variable in your terminal to store your `-cc`
and `-cflags` settings, rather than including them in the build command each time.

### #pkgconfig

Add `#pkgconfig` directives to tell the compiler which modules should be used for compiling
and linking using the pkg-config files provided by the respective dependencies.

As long as backticks can't be used in `#flag` and spawning processes is not desirable for security
and portability reasons, V uses its own pkgconfig library that is compatible with the standard
freedesktop one.

If no flags are passed it will add `--cflags` and `--libs` to pkgconfig (not to V).
In other words, both lines below do the same:

```v oksyntax
#pkgconfig r_core
#pkgconfig --cflags --libs r_core
```

The `.pc` files are looked up into a hardcoded list of default pkg-config paths, the user can add
extra paths by using the `PKG_CONFIG_PATH` environment variable. Multiple modules can be passed.

To check the existence of a pkg-config use `$pkgconfig('pkg')` as a compile time "if" condition to
check if a pkg-config exists. If it exists the branch will be created. Use `$else` or `$else $if`
to handle other cases.

```v ignore
$if $pkgconfig('mysqlclient') {
	#pkgconfig mysqlclient
} $else $if $pkgconfig('mariadb') {
	#pkgconfig mariadb
}
```

### Including C code

You can also include C code directly in your V module.
For example, let's say that your C code is located in a folder named 'c' inside your module folder.
Then:

* Put a v.mod file inside the toplevel folder of your module (if you
  created your module with `v new` you already have v.mod file). For example:

```v ignore
Module {
	name: 'mymodule',
	description: 'My nice module wraps a simple C library.',
	version: '0.0.1'
	dependencies: []
}
```

* Add these lines to the top of your module:

```v oksyntax
#flag -I @VMODROOT/c
#flag @VMODROOT/c/implementation.o
#include "header.h"
```

> [!NOTE]
> @VMODROOT will be replaced by V with the *nearest parent folder,
> where there is a v.mod file*.
> Any .v file beside or below the folder where the v.mod file is,
> can use `#flag @VMODROOT/abc` to refer to this folder.
> The @VMODROOT folder is also *prepended* to the module lookup path,
> so you can *import* other modules under your @VMODROOT, by just naming them.

The instructions above will make V look for an compiled .o file in
your module `folder/c/implementation.o`.
If V finds it, the .o file will get linked to the main executable, that used the module.
If it does not find it, V assumes that there is a `@VMODROOT/c/implementation.c` file,
and tries to compile it to a .o file, then will use that.

This allows you to have C code, that is contained in a V module, so that its distribution is easier.
You can see a complete minimal example for using C code in a V wrapper module here:
[project_with_c_code](https://github.com/vlang/v/tree/master/vlib/v/tests/project_with_c_code).
Another example, demonstrating passing structs from C to V and back again:
[interoperate between C to V to C](https://github.com/vlang/v/tree/master/vlib/v/tests/project_with_c_code_2).

### C types

Ordinary zero terminated C strings can be converted to V strings with
`unsafe { &char(cstring).vstring() }` or if you know their length already with
`unsafe { &char(cstring).vstring_with_len(len) }`.

> [!NOTE]
> The `.vstring()` and `.vstring_with_len()` methods do NOT create a copy of the `cstring`,
> so you should NOT free it after calling the method `.vstring()`.
> If you need to make a copy of the C string (some libc APIs like `getenv` pretty much require that,
> since they return pointers to internal libc memory), you can use `cstring_to_vstring(cstring)`.

On Windows, C APIs often return so called `wide` strings (utf16 encoding).
These can be converted to V strings with `string_from_wide(&u16(cwidestring))` .

V has these types for easier interoperability with C:

- `voidptr` for C's `void*`,
- `&u8` for C's `byte*` and
- `&char` for C's `char*`.
- `&&char` for C's `char**`

To cast a `voidptr` to a V reference, use `user := &User(user_void_ptr)`.

`voidptr` can also be dereferenced into a V struct through casting: `user := User(user_void_ptr)`.

[an example of a module that calls C code from V](https://github.com/vlang/v/blob/master/vlib/v/tests/project_with_c_code/mod1/wrapper.c.v)

### C Declarations

C identifiers are accessed with the `C` prefix similarly to how module-specific
identifiers are accessed. Functions must be redeclared in V before they can be used.
Any C types may be used behind the `C` prefix, but types must be redeclared in V in
order to access type members.

To redeclare complex types, such as in the following C code:

```c
struct SomeCStruct {
	uint8_t implTraits;
	uint16_t memPoolData;
	union {
		struct {
			void* data;
			size_t size;
		};

		DataView view;
	};
};
```

members of sub-data-structures may be directly declared in the containing struct as below:

```v
pub struct C.SomeCStruct {
	implTraits  u8
	memPoolData u16
	// These members are part of sub data structures that can't currently be represented in V.
	// Declaring them directly like this is sufficient for access.
	// union {
	// struct {
	data voidptr
	size usize
	// }
	view C.DataView
	// }
}
```

The existence of the data members is made known to V, and they may be used without
re-creating the original structure exactly.

Alternatively, you may [embed](#embedded-structs) the sub-data-structures to maintain
a parallel code structure.

### Export to shared library

By default all V functions have the following naming scheme in C: `[module name]__[fn_name]`.

For example, `fn foo() {}` in module `bar` will result in `bar__foo()`.

To use a custom export name, use the `@[export]` attribute:

```
@[export: 'my_custom_c_name']
fn foo() {
}
```

### Translating C to V

V can translate your C code to human readable V code, and generating V wrappers
on top of C libraries.

C2V currently uses Clang's AST to generate V, so to translate a C file to V
you need to have Clang installed on your machine.

Let's create a simple program `test.c` first:

```c
#include "stdio.h"

int main() {
	for (int i = 0; i < 10; i++) {
		printf("hello world\n");
	}
        return 0;
}
```

Run `v translate test.c`, and V will generate `test.v`:

```v
fn main() {
	for i := 0; i < 10; i++ {
		println('hello world')
	}
}
```

To generate a wrapper on top of a C library use this command:

```bash
v translate wrapper c_code/libsodium/src/libsodium
```

This will generate a directory `libsodium` with a V module.

Example of a C2V generated libsodium wrapper:

https://github.com/vlang/libsodium

<br>

When should you translate C code and when should you simply call C code from V?

If you have well-written, well-tested C code,
then of course you can always simply call this C code from V.

Translating it to V gives you several advantages:

- If you plan to develop that code base, you now have everything in one language,
  which is much safer and easier to develop in than C.
- Cross-compilation becomes a lot easier. You don't have to worry about it at all.
- No more build flags and include files either.

### Working around C issues

In some cases, C interop can be extremely difficult.
One of these such cases is when headers conflict with each other.
For example, V needs to include the Windows header libraries in order for your V binaries to work
seamlessly across all platforms.

However, since the Windows header libraries use extremely generic names such as `Rectangle`,
this will cause a conflict if you wish to use C code that also has a name defined as `Rectangle`.

For very specific cases like this, we have `#preinclude`.

This will allow things to be configured before V adds in its built in libraries.

Example usage:
```v ignore
// This will include before built in libraries are used.
#preinclude "pre_include.h"
// This will include after built in libraries are used.
#include "include.h"
```

An example of what might be included in `pre_include.h`
can be [found here](https://github.com/irishgreencitrus/raylib.v/blob/main/include/pre.h)

This is an advanced feature, and will not be necessary
outside of very specific cases with C interop,
meaning it could cause more issues than it solves.

Consider it last resort!

## Other V Features

### Inline assembly

<!-- ignore because it doesn't pass fmt test (why?) -->

```v ignore
a := 100
b := 20
mut c := 0
asm amd64 {
    mov eax, a
    add eax, b
    mov c, eax
    ; =r (c) as c // output
    ; r (a) as a // input
      r (b) as b
}
println('a: ${a}') // 100
println('b: ${b}') // 20
println('c: ${c}') // 120
```

For more examples, see
[vlib/v/slow_tests/assembly/asm_test.amd64.v](https://github.com/vlang/v/tree/master/vlib/v/slow_tests/assembly/asm_test.amd64.v)

### Hot code reloading

```v live
module main

import time

@[live]
fn print_message() {
	println('Hello! Modify this message while the program is running.')
}

fn main() {
	for {
		print_message()
		time.sleep(500 * time.millisecond)
	}
}
```

Build this example with `v -live message.v`.

You can also run this example with `v -live run message.v`.
Make sure that in command you use a path to a V's file,
**not** a path to a folder (like `v -live run .`) -
in that case you need to modify content of a folder (add new file, for example),
because changes in *message.v* will have no effect.

Functions that you want to be reloaded must have `@[live]` attribute
before their definition.

Right now it's not possible to modify types while the program is running.

More examples, including a graphical application:
[github.com/vlang/v/tree/master/examples/hot_reload](https://github.com/vlang/v/tree/master/examples/hot_reload).

#### About keeping states in hot reloading functions with v -live run
V's hot code reloading relies on marking the functions that you want to reload with `@[live]`,
then compiling a shared library of these `@[live]` functions, and then
your v program loads that shared library at runtime.

V (with the -live option) starts a new thread, that monitors the source files for changes,
and when it detects modifications, it recompiles the shared library, and reloads it at runtime,
so that new calls to those @[live] functions will be made to the newly loaded library.

It keeps all the accumulated state (from locals outside the @[live] functions,
from heap variables and from globals), allowing to tweak the code in the merged functions quickly.

When there are more substantial changes (to data structures, or to functions that were not marked),
you will have to restart the running app manually.

### Cross-platform shell scripts in V

V can be used as an alternative to Bash to write deployment scripts, build scripts, etc.

The advantage of using V for this, is the simplicity and predictability of the language, and
cross-platform support. "V scripts" run on Unix-like systems, as well as on Windows.

To use V's script mode, save your source file with the `.vsh` file extension.
It will make all functions in the `os` module global (so that you can use `mkdir()` instead
of `os.mkdir()`, for example).

V also knows to compile & run `.vsh` files immediately, so you do not need a separate
step to compile them. V will also recompile an executable, produced by a `.vsh` file,
*only when it is older than the .vsh source file*, i.e. runs after the first one, will
be faster, since there is no need for a re-compilation of a script, that has not been changed.

An example `deploy.vsh`:

```v oksyntax
#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

// Note: The shebang line above, associates the .vsh file to V on Unix-like systems,
// so it can be run just by specifying the path to the .vsh file, once it's made
// executable, using `chmod +x deploy.vsh`, i.e. after that chmod command, you can
// run the .vsh script, by just typing its name/path like this: `./deploy.vsh`

// print command then execute it
fn sh(cmd string) {
	println('❯ ${cmd}')
	print(execute_or_exit(cmd).output)
}

// Remove if build/ exits, ignore any errors if it doesn't
rmdir_all('build') or {}

// Create build/, never fails as build/ does not exist
mkdir('build')!

// Move *.v files to build/
result := execute('mv *.v build/')
if result.exit_code != 0 {
	println(result.output)
}

sh('ls')

// Similar to:
// files := ls('.')!
// mut count := 0
// if files.len > 0 {
//     for file in files {
//         if file.ends_with('.v') {
//              mv(file, 'build/') or {
//                  println('err: ${err}')
//                  return
//              }
//         }
//         count++
//     }
// }
// if count == 0 {
//     println('No files')
// }
```

Now you can either compile this like a normal V program and get an executable you can deploy and run
anywhere:
`v -skip-running deploy.vsh && ./deploy`

Or run it like a traditional Bash script:
`v run deploy.vsh` (or simply just `v deploy.vsh`)

On Unix-like platforms, the file can be run directly after making it executable using `chmod +x`:
`./deploy.vsh`

### Vsh scripts with no extension

Whilst V does normally not allow vsh scripts without the designated file extension, there is a way
to circumvent this rule and have a file with a fully custom name and shebang. Whilst this feature
exists it is only recommended for specific usecases like scripts that will be put in the path and
should **not** be used for things like build or deploy scripts. To access this feature start the
file with `#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run
the built executable. This will run in crun mode so it will only rebuild if changes to the script
were made and keep the binary as `tmp.<scriptfilename>`. **Caution**: if this filename already
exists the file will be overridden. If you want to rebuild each time and not keep this binary
instead use `#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

# Appendices

## Appendix I: Keywords

V has 44 reserved keywords (3 are literals):

```v ignore
as
asm
assert
atomic
break
const
continue
defer
else
enum
false
fn
for
go
goto
if
import
in
interface
is
isreftype
lock
match
module
mut
none
or
pub
return
rlock
select
shared
sizeof
spawn
static
struct
true
type
typeof
union
unsafe
volatile
__global
__offsetof
```

See also [V Types](#v-types).

## Appendix II: Operators

This lists operators for [primitive types](#primitive-types) only.

```v ignore
+    sum                    integers, floats, strings
-    difference             integers, floats
*    product                integers, floats
/    quotient               integers, floats
%    remainder              integers

~    bitwise NOT            integers
&    bitwise AND            integers
|    bitwise OR             integers
^    bitwise XOR            integers

!    logical NOT            bools
&&   logical AND            bools
||   logical OR             bools
!=   logical XOR            bools

<<   left shift             integer << unsigned integer
>>   right shift            integer >> unsigned integer
>>>  unsigned right shift   integer >> unsigned integer


Precedence    Operator
    5            *  /  %  <<  >> >>> &
    4            +  -  |  ^
    3            ==  !=  <  <=  >  >=
    2            &&
    1            ||


Assignment Operators
+=   -=   *=   /=   %=
&=   |=   ^=
>>=  <<=  >>>=
&&= ||=
```
