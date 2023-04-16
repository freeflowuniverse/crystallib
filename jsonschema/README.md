# JSON Schema


# Encoding to V

Currently, to encode a JSON Schema to V, the schema must satisfy the following assumptions:
- each object in schema must have a title

## Struct Names 

When generating structs from schema objects, the encoder uses the title of the schema object to name the struct. The title is converted to PascalCase and used as the structs name. 

## Recursive Schemas

In V, recursive structs are written with sumtypes. The Schema library doesn't support sumtypes yet, and as such recursive schemas can't be encoded into V.