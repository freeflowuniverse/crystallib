# module ui.console

has mechanisms to print better to console, see the methods below

import as 

```vlang
import freeflowuniverse.crystallib.ui.console

```


## Methods

```v

fn clear()
    //reset the console screen

fn color_bg(c BackgroundColor) string
    // will give ansi codes to change background color . dont forget to call reset to change back to normal

fn color_fg(c ForegroundColor) string
    // will give ansi codes to change foreground color . don't forget to call reset to change back to normal

struct PrintArgs {
pub mut:
	foreground   ForegroundColor
	background   BackgroundColor
	text         string
	style        Style
	reset_before bool = true
	reset_after  bool = true
}

fn cprint(args PrintArgs)
    // print with colors, reset...
    // ```
    //  	foreground ForegroundColor
    //  	background BackgroundColor
    //  	text string
    //  	style Style
    //  	reset_before bool = true
    //  	reset_after bool = true
    // ```

fn cprintln(args_ PrintArgs)

fn expand(txt_ string, l int, with string) string
    // expand text till length l, with string which is normally ' '

fn lf()
    line feed

fn new() UIConsole

fn print_array(arr [][]string, delimiter string, sort bool)
    // print 2 dimensional array, delimeter is between columns

fn print_debug(i IPrintable)

fn print_debug_title(title string, txt string)

fn print_green(txt string)

fn print_header(txt string)

fn print_item(txt string)

fn print_lf(nr int)

fn print_stderr(txt string)

fn print_stdout(txt string)

fn reset() string

fn silent_get() bool

fn silent_set()

fn silent_unset()

fn style(c Style) string
    // will give ansi codes to change style . don't forget to call reset to change back to normal

fn trim(c_ string) string

```

## Console Object

Is used to ask feedback to users


```v

struct UIConsole {
pub mut:
	x_max      int = 80
	y_max      int = 60
	prev_lf    bool
	prev_title bool
	prev_item  bool
}

//DropDownArgs:
// - description string 
// - items []string 
// - warning     string 
// - clear       bool = true


fn (mut c UIConsole) ask_dropdown_int(args_ DropDownArgs) !int
    // return the dropdown as an int 

fn (mut c UIConsole) ask_dropdown_multiple(args_ DropDownArgs) ![]string
    // result can be multiple, aloso can select all description string items       []string warning     string clear       bool = true

fn (mut c UIConsole) ask_dropdown(args DropDownArgs) !string
    // will return the string as given as response description

// QuestionArgs:
// - description string
// - question string
// - warning: string (if it goes wrong, which message to use)
// - reset bool = true
// - regex: to check what result need to be part of
// - minlen: min nr of chars

fn (mut c UIConsole) ask_question(args QuestionArgs) !string

fn (mut c UIConsole) ask_time(args QuestionArgs) !string

fn (mut c UIConsole) ask_date(args QuestionArgs) !string

fn (mut c UIConsole) ask_yesno(args YesNoArgs) !bool
    // yes is true, no is false 
    // args:
    // - description string
    // - question string
    // - warning string
    // - clear bool = true

fn (mut c UIConsole) reset()

fn (mut c UIConsole) status() string

```



## enums


```v
enum BackgroundColor {
	default_color = 49 // 'default' is a reserved keyword in V	
	black         = 40
	red           = 41
	green         = 42
	yellow        = 43
	blue          = 44
	magenta       = 45
	cyan          = 46
	light_gray    = 47
	dark_gray     = 100
	light_red     = 101
	light_green   = 102
	light_yellow  = 103
	light_blue    = 104
	light_magenta = 105
	light_cyan    = 106
	white         = 107
}
enum ForegroundColor {
	default_color = 39 // 'default' is a reserved keyword in V	
	white         = 97
	black         = 30
	red           = 31
	green         = 32
	yellow        = 33
	blue          = 34
	magenta       = 35
	cyan          = 36
	light_gray    = 37
	dark_gray     = 90
	light_red     = 91
	light_green   = 92
	light_yellow  = 93
	light_blue    = 94
	light_magenta = 95
	light_cyan    = 96
}
enum Style {
	normal    = 99
	bold      = 1
	dim       = 2
	underline = 4
	blink     = 5
	reverse   = 7
	hidden    = 8
}

```
