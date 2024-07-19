# Markdown parser specs

This document specifies the requirements for elements, or how the parser sees them, and how the parser works.

## Element Specs

### Action element

- Starts with `!`
- Content is considered after `!` and until a line is reached that does not begin with a space or EOF (line that does not start with a space is excluded).

### Codeblock element

- Starts with ```.
- Content is considered from next line after \```, and until a line that starts with \```.
- Text after beginning or ending backticks is ignored.

### HTML element

- Starts with `<html>`
- Content is considered from next line after `<html>`, and until a line that starts with `</html>`
- Text after beginning or ending tags is ignored.

### Header element

- Starts with `#`
- Content is considered only from the same line, excluding any `#` characters
- Depth, or number of `#`, must be positive and <= 6

### Table element

- Starts and ends with a `|`
- Content is considered for each line that starts and ends with `|` and until a line is reached that does not meet this requirement.

### Comment element

- Starts with `<!--` and ends with `-->`
- Content is considered from after start and before end.

### Paragraph element

- This is the default element, any content that does not belong to another element belongs to a paragraph.

## How it works

The markdown parser is very simple. it reads content line by line, with the default element specified as a paragraph.
If the last element is a paragraph, then the parser searches for a new element's beginning, and if there is a match, the new element is appended to the list of parsed elements, if there is no match, the content is added to the last paragraph.
If the last element is not a paragraph, then the parser searches for the last element's ending, and if there is a match, a new paragraph is appended to the list of parsed elements, if there is no match, content is added to the last element.
