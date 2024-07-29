# Node Template: @{nodetemplate.name}

## Capacity

- CRU: @{nodetemplate.capacity.cru}
- MRU: @{nodetemplate.capacity.mru} GB
- SRU: @{nodetemplate.capacity.sru} GB
- HRU: @{nodetemplate.capacity.hru} GB

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