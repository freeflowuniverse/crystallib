# Files

https://github.com/v-community/v_by_example/blob/master/en/examples/section_4/files.md

## Find

```vlang
```


## Read Lines

```vlang

contents := os.read_file(path.trim_space()) or {
    println('Failed to open $path')
    return
}

for line in contents.split_into_lines() {
    println (line)
  }
}

```
