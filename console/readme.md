# Console utility functions



## Chalk

A terminal string colorizer for the [V language](https://vlang.io).

Chalk offers functions:
- `console.color_fg(text string, color string)` - To change the foreground color.
- `console.color_bg(text string, color string)` - To change the background color.
- `console.style(text string, style string)` - To change the text style.

Example:

```v
import console

# basic usage
println('I am really ' + console.color_fg('happy', 'green'))

# you can also nest them
println('I am really ' + console.color_fg(console.style('ANGRY', 'bold'), 'red'))
```

Available colors:
- black
- red
- green
- yellow
- blue
- magenta
- cyan
- default
- light_gray
- dark_gray
- light_red
- light_green
- light_yellow
- light_blue
- light_magenta
- light_cyan
- white

Available styles:
- bold
- dim
- underline
- blink
- reverse
- hidden