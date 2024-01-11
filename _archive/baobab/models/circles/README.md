# Circles

The twin's data structure unit.

## Terminology

- Circle: a unit for organizing data. Can have multiple members.
- Root object: a data structure that belongs directly to the circle, has a unique id. Can have sub objects.
- Sub Object: any non-root object that has to belong to one and only one root object.
- Definer: a word used in the code to describe a method that defines an object in the circle. Like a factory function.

## Root Objects

## Code generation

This module only requires the models of root objects that belong to circles to be defined. The circle methods for defining these objects (definers), and 3script parsers for each actions defining objects are generated.

To generate definer methods and 3Script action parsers for a model, run:

`v run <path/to/crystallib>/circles/gen <model_name>`

This will generate the following files in the root of this module:
- <modelname>_definers.v
- <modelname>_actions.v

## Models

Models are models of root object data structures, organized by category.

### Organization

Model of organizational structures for the circles

Root objects:
- Epic
- Story
- Calendar