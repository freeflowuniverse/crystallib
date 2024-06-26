# Node Information

## Basic Details

- **ID**: ${node.id}
- **Name**: ${node.name}
- **Cost**: ${node.cost} USD
- **Delivery Time**: ${node.deliverytime}
- **Description**: ${node.description}
- **CPU Brand**: ${node.cpu_brand}
- **CPU Version**: ${node.cpu_version}
- **Memory**: ${node.mem}
- **Hard Disk Drive**: ${node.hdd}
- **Solid State Drive**: ${node.ssd}
- **Vendor**: ${node.vendor}
- **Image**: ![Node Image](${node.image})

## Performance

- **Passmark**: ${node.passmark}
- **Uptime**: ${node.uptime}%
- **Reputation**: ${node.reputation}

## Location

- **Continent**: ${node.continent}
- **Country**: ${node.country}

## Links

- **More Information**: [Visit Here](${node.url})

## Financials

- **INCA Reward**: ${node.inca_reward}
- **Grant Details**: 
  - **USD per Month**: ${node.grant.grant_month_usd}
  - **INCA per Month**: ${node.grant.grant_month_inca}
  - **Max Number of Nodes**: ${node.grant.grant_max_nrnodes}

## Cloud Box Configuration

${ for cloudbox in node.aibox }
- **Amount**: ${cloudbox.amount}
- **Core Memory**: ${cloudbox.mem_gb} GB
- **Storage**: ${cloudbox.storage_gb} GB
- **Virtual Cores**: ${cloudbox.vcores}
- **Price Range**: ${cloudbox.price_range[0]} - ${cloudbox.price_range[1]} USD
- **Price Simulation**: ${cloudbox.price_simulation} USD
${ end }


## AI Box Configuration

${ for aibox in node.aibox }
- **Amount**: ${aibox.amount}
- **GPU Brand**: ${aibox.gpu_brand}
- **GPU Version**: ${aibox.gpu_version}
- **GPU Memory**: ${aibox.mem_gb_gpu} GB
- **Core Memory**: ${aibox.mem_gb} GB
- **Storage**: ${aibox.storage_gb} GB
- **Virtual Cores**: ${aibox.vcores}
- **Price Range**: ${aibox.price_range[0]} - ${aibox.price_range[1]} USD
- **Price Simulation**: ${aibox.price_simulation} USD
${ end }

## Storage Box Configuration

${ for storagebox in node.storagebox }
- **Amount**: ${storagebox.amount}
- **Description**: ${storagebox.description}
- **Price Range**: ${storagebox.price_range[0]} - ${storagebox.price_range[1]} USD
- **Price Simulation**: ${storagebox.price_simulation} USD
${ end }
