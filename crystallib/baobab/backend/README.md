# Backend

The purpose is to research ways in which actors can use generated code to use different ways of storing root objects. 

## Database Drivers

The `Backend` employs two database drivers:
- `Indexer`, which drives an SQLite Database used to store base object `gid`'s with relevant indexes
- `DBCollection` which drives a collection of filesystem databases with encryption support

## Generic Code

The solution provided by this module is to create a backend interface with generic CRUD + list + filter methods for root objects that different backends can implement.

This allows for a single generated actor code to use different backends, without having to generate separate code for each. Having less generated code is less prone to errors, and using the same backend methods for each actor makes it easier modify, fix and add features to the backends. Using the same data manipulation methods in generated code also makes it easier to generate code for the actor as the implementations don't differ for different root objects.