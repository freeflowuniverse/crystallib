# VDC technical concept

## definition heroscript

A VDC is defined through heroscript. It's a declarative language to describe a VDC and is parsed into an in-memory model.

**What** instead of **How-to**.

## query heroscript

heroscript that queries the deployed state on the grid (reality). The output can be json for machine parsing or markdown for human interpretation.

## change actions heroscript

A heroscript with the actions needed to bring the reality to the desired state defined in the definition heroscript.
These are heroscript actions executed through the web3gw.

This is also referred to as a "request for change script" as it can go to a person or DAO to approve or be executed immediately.

An extra benefit is that it gives auditing of the applied changes if it is stored in a version control system for example.

## from definition to reality

1. The definition heroscript is parsed to an in memory model.
2. A query heroscript is generated to query the reality.
3. The query heroscript is executed and an action heroscript is generated (the web3gw sal is not called directly to align relity to the model)
4. The action heroscript is executed to bring reality in the desired state

## Naming

The name of any instance, being a vm or something else should be unique within a VDC regardless of the type.

The name as created on the grid is `vdc.<vdc_name>.<instance_name>`. This implies that the `.` character is not allowed in a vdc name or an instance name.
