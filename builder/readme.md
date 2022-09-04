# BUILDER

## Initialization

```vlang

```

## NODE DB

There is a type of database implemented on a node level, its basically a key value stor stored on the node.

Very useful to store values we don't wanna forget.

## EXECUTOR

We have executors implemented to work over SSH or for the LOCAL machine.

Each executor implements the following methods

- exec(cmd string) ?string
- exec_silent(cmd string) ?string
- file_write(path string, text string) ?
- file_read(path string) ?string
- file_exists(path string) bool
- delete(path string) ?
- download(source string, dest string) ?
- upload(source string, dest string) ?
- environ_get() ?map[string]string
- info() map[string]string
- shell(cmd string) ?
- list(path string) ?[]string
- dir_exists(path string) bool
- debug_off()
- debug_on()

## TMUX

TMUX is a very capable process manager, this class makes it easier to operate.

example:

```v


```

A cool feature is that we can run TMUX remote over an SSH node.

### Concepts

- tmux = is the factory, it represents the tmux process manager, linked to a node
- session = is a set of windows, it has a name and groups windows
- window = is typically one process running (you can have panes but in our implementation we skip this)

