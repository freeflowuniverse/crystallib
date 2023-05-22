# Code Model

A set of models that represent code, such as structs and functions. The motivation behind this module is to provide a more generic, and lighter alternative to v.ast code models, that can be used for code parsing and code generation across multiple languages.

## Using Codemodel

While the models in this module can be used in any domain, the models here are used extensively in the modules [codeparser](../codeparser/) and codegen (under development). Below are examples on how codemodel can be used for parsing and generating code.
## Code parsing with codemodel

As shown in the example below, the codemodels returned by the parser can be used to infer information about the code written

```js
code := codeparser.parse("somedir") // code is a list of code models

num_functions := code.filter(it is Function).len
structs := code.filter(it is Struct)
println("This directory has ${num_functions} functions")
println('The directory has the structs: ${structs.map(it.name)}')

```

or can be used as intermediate structures to serialize code into some other format:

```js
code_md := ''

// describes the struct in markdown format
for struct in structs {
    code_md += '# ${struct.name}'
    code_md += 'Type: ${struct.typ.symbol}'
    code_md += '## Fields:'
    for field in struct.fields {
        code_md += '- ${field.name}'
    }
}
```

The [openrpc/docgen](../openrpc/docgen/) module demonstrates a good use case, where codemodels are serialized into JSON schema's, to generate an OpenRPC description document from a client in v.