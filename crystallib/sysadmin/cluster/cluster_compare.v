module cluster

//TODO: doesnt work yet needs to be checked and fixed

pub fn compare_clusters(old Cluster, new Cluster) []string {
    mut changes := []string{}

    // Check for removed nodes
    for old_node in old.nodes {
        if !new.node_exists(old_node.nr) {
            changes << 'Node ${old_node.nr} (${old_node.name}) was removed'
        }
    }

    // Check for removed services
    for old_service in old.services {
        if !new.service_exists(old_service.name) {
            changes << 'Service ${old_service.name} was removed'
        }
    }

// Check for service changes (new ports, new nodes)
    for old_service in old.services {
        new_service := new.services.filter(it.name == old_service.name)
        if new_service.len > 0 {
            // Check for new ports
            for port in new_service[0].port {
                if port !in old_service.port {
                    changes << 'Service ${old_service.name} got a new port: ${port}'
                }
            }
            for port in new_service[0].port_public {
                if port !in old_service.port_public {
                    changes << 'Service ${old_service.name} got a new public port: ${port}'
                }
            }

            // Check for new nodes
            for node in new_service[0].nodes {
                if node !in old_service.nodes {
                    changes << 'Service ${old_service.name} was put on a new node: ${node}'
                }
            }
        }
    }

    // Check for removed admins
    for old_admin in old.admins {
        if !new.admins.any(it.name == old_admin.name) {
            changes << 'Admin ${old_admin.name} was removed'
        }
    }

    // Check for added nodes
    for new_node in new.nodes {
        if !old.node_exists(new_node.nr) {
            changes << 'Node ${new_node.nr} (${new_node.name}) was added'
        }
    }

    // Check for added services
    for new_service in new.services {
        if !old.service_exists(new_service.name) {
            changes << 'Service ${new_service.name} was added'
        }
    }

    // Check for added admins
    for new_admin in new.admins {
        if !old.admins.any(it.name == new_admin.name) {
            changes << 'Admin ${new_admin.name} was added'
        }
    }

    // Check for changed IP addresses
    for old_admin in old.admins {
        new_admin := new.admins.filter(it.name == old_admin.name)
        if new_admin.len > 0 && old_admin.ipaddress != new_admin[0].ipaddress {
            changes << 'Admin ${old_admin.name} got a different IP address: ${new_admin[0].ipaddress}'
        }
    }

    return changes
}