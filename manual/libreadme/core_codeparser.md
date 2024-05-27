# Code Parser

A library of code parsers that parse code and comments into defined code primitives in the [CodeModel](../codemodel/README.md) library.

## What it does

- The codeparser parses code into the same generic code models.

This allows programs that use the code parser to be able to parse from all the languages the codeparser library supports (though currently only V) without having to change implementation.

- The codeparser parses comments into the code models.

This introduces styling guidelines around writing comments in programming languages, which if used can help the parser parse in a lot of structured information into code models. See for instance how the codeparser can harvest a lot of information from the below V function's comments:

```go
// hello generates a list of greeting strings for a specific name
// - name: the name of the person being greeted
// - times: the number of greeting messages to be generated
// returns hello messages, a list of messages that greets a person with their name
fn hello(name string, times int) []string {
    return "hello $name"
}
```

The VParser parses the above function into the following models:

```py
Function {
    name: 'hello'
    description: 'generates a greeting string for a specific name'
    body: 'return "hello $name"'
    params: [
        Param {
            name: 'name'
            description: 'the name of the person being greeted'
            typ: Type {
                symbol: 'string'
            }
        },
        Param {
            name: 'times'
            description: 'the number of greeting messages to be generated'
            typ: Type {
                symbol: 'int'
            }
        }
    ]
    result: Result {
        name: 'hello messages'
        description: 'a list of messages that greets a person with their name'
        typ: Type {
            symbol: '[]string'
        }
    }
}
```

While this example contains a lot of comments for a simple function, this can come in especially useful when parsing more complex functions, and parsing for documentation generation (see [OpenRPC Document Generator](#openrpc-document-generator)).

## Getting started

1. Have a code directory or file to parse.
2. Follow annotations guidelines for the coding languages in your project to annotate your code in the format codeparser can parse from.
3. Run `v run `

## Annotations

Currently, the codeparser can parse annotations on struct declarations and function declarations, and gather the following information: 

**Struct declaration annotations** 

- struct description
- field descriptions for each field

**Function declaration annotations** 

- function description
- parameter descriptions for each parameter
- result name and description of what the function returns

The codeparser expects code to be annotated in a certain format to be able to parse descriptive comments into ['code items'](). While failure to follow this formatting won't cause any errors, some of the comments may end up not being parsed into the ['code model']() outputted. The format of annotations expected in each programming language the codeparser supports are detailed below.

### Annotating code in V

- Struct annotations:

```go
// this is a description of the struct
struct Example {
    field0 string // this comment describes field0
    field1 int // this comment describes field1
}
```

This struct is parsed as the following:

```py
Struct {
    name: 'Example'
    description: 'this is a description of the struct'
    fields: [
        StructField {
            name: 'field0'
            description: 'this comment describes field0'
            typ: Type {
                symbol: 'string'
            }
        },
        StructField {
            name: 'field1'
            description: 'this comment describes field1'
            typ: Type {
                symbol: 'int'
            }
        }
    ]
}
```

- Function annotations:

```go
// some_function is described by the words following the functions name
// - param0: this sentence after the colon describes param0
// - param1: this sentence after the colon describes param1
// returns the desired result, this sentence after the comma describes 'the desired result'
fn some_function(param0 string, param1 int) result []string {}
```

This function is parsed as the following: 

```py
Function {
    name: 'some_function'
    description: 'is described by the words following the functions name'
    body: ''
    params: [
        Param {
            name: 'param0'
            description: 'this sentence after the colon describes param0'
            typ: Type {
                symbol: 'string'
            }
        },
        Param {
            name: 'param1'
            description: 'this sentence after the colon describes param1'
            typ: Type {
                symbol: 'int'
            }
        }
    ]
    result: Result {
        name: 'the desired result'
        description: 'this sentence after the comma describes \'the desired result\''
        typ: Type {
            symbol: '[]string'
        }
    }
}
```

## VParser

NB: v.parser refers to the parser in v standard library, whereas  VParser refers to the codeparser for V in this module.

The VParser uses the v.ast and v.parser libraries to parse through the code in V files. The main purpose of the VParser in this library is to provide a simpler alternative to the builtin v.parser, for less complex applications. As the v.parser module is used in parsing and compiling V itself, it's ast models for function and struct declarations come with a lot of overhead that is not necessary for simpler applications.

### Using VParser

The vparser contains only one public function: `pub fn parse_v(path_ string, parser VParser)`.

The VParser struct can be configured to determine how the parsing should be done on a path_ containing V files. See the [docs]() for more information on using the parse_v function.

### Example applications

#### [OpenRPC Document Generator](../openrpc/docgen/)

The OpenRPC document generator uses the VParser to parse through OpenRPC Client code in V, to create an OpenRPC Document from the parsed code.
