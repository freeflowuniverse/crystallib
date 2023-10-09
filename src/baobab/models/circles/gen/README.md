# Circles Code Generation

This module is responsible for generating definers and 3script action parser for circle models. Read [circles](circles/README.md) first.

## Generating Definers

### Root Object Definers

Each root object is stored in a map of references in the circle structure. As such, the definer of a circle simply creates an instance of the root object and stores it in the associated map field in `struct Circle`. The code generator knows which `Circle` field to store the created root object by finding the field with the `map` corresponding to the root object. For instance the root object `Story` is automatically stored in the `Circle.stories` field in the below example.

```
struct Circle {
pub mut:
    stories map[string]&Story
}

[root_object]
struct Story{}

fn (mut circle Circle) story_definer(story Story) {
    circle.stories << story // generated definer stores story in correct field
}
```

### Definers for sub objects

Unlike root objects which have a common way of being stored in the `Circle` struct, sub objects can be stored in different 
For sub objects, the definer must know 

## Contributing

It's recommended to take a look at [crystallib/codemodel](codemodel/README.md) and [crystallib/codeparser](codeparser/README.md) before diving into contributing to the code generation module.

**IMPORTANT**

The code generation module used in circles should not overwrite any intentionally modified code unless explicitly configured to do so. This should be done with a `--force` flag, and the user should be warned of changes beforehand.