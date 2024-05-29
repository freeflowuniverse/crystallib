# JSON Schema

A V library for the JSON Schema model, and a few handy functions. 

## JSON Schema Model

Defined [here](https://json-schema.org/), "JSON Schema is a declarative language that allows you to annotate and validate JSON documents." The model in this module provides a struct that can easily be encoded into a JSON Schema.

## Generating a Schema

The generate.v file provides functions that can generate JSONSchema from [codemodels](../codemodel/). This allows for easy generation of JSON Schema from structs, and is useful for generating schemas from parsed code in v.

Example: 
```go
struct_ := codemodel.Struct {
    name: "Mystruct"
    fields: [
        codemodel.StructField {
            name: "myfield"
            typ: "string"
        }
    ]
}
schema := struct_to_schema(struct_)
```

### Generating Schemas for Anonymous Structs

The properties of a JSON Schema is a list of key value pairs, where keys represent the subschema's name and the value is the schema (or the reference to the schema which is defined elsewhere) of the property. This is analogous to the fields of a struct, which is represented by a field name and a type.

It's good practice to define object type schemas separately and reference them in properties, especially if the same schema is used in multiple places. However, object type schemas can also be defined in property definitions. This may make sense if the schema is exclusively used as a property of a schema, similar to using an anonymous struct for the type definition of a field of a struct.

As such, schema's generated from structs that declare anonymous structs as field types, include a schema definition in the property field.

## Notes

As [this issue](https://github.com/vlang/v/issues/15081) is still not resolved, a json schema cannot be decoded into the json schema structure defined in this module. As such, to decode json schema string into a structure the `pub fn decode(data str) !Schema` function defined in `decode.v` must be used.