# Node Template: @{nodetemplate.name}

## Capacity

- CRU: @{nodetemplate.capacity.resourceunits.cru}
- MRU: @{nodetemplate.capacity.resourceunits.mru} GB
- SRU: @{nodetemplate.capacity.resourceunits.sru} GB
- HRU: @{nodetemplate.capacity.resourceunits.hru} GB

## Components

| Component | Quantity |
|-----------|----------|
@for group in nodetemplate.components
| @{group.name} | @{group.nr} |
@end

## Detailed Component Information

@for group in nodetemplate.components

### @{group.name} (x@{group.nr})

- Description: @{group.component.description}
- Cost: $@{group.component.cost:.2f}
- Rackspace: @{group.component.rackspace} U
- Power: @{group.component.power} W
- CRU: @{group.component.cru}
- MRU: @{group.component.mru} GB
- HRU: @{group.component.hru} GB
- SRU: @{group.component.sru} GB

@end