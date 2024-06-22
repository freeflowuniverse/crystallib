module cloudslices

import time


pub struct Node {
pub mut:
    id              int
    name            string
    cost            f64
    deliverytime    time.Time
    description     string
    cpu_brand       string
    cpu_version     string
    inca_reward     int
    image           string
    mem             string
    hdd             string
    ssd             string
    url             string
    reputation      int
    uptime          int
    continent       string
    country         string
    passmark        int
    cloudbox        []CloudBox
    aibox           []AIBox
    storagebox      []StorageBox
    vendor          string
    grant      NodeGrant

}

pub struct NodeGrant {
pub mut:
    grant_month_usd string
    grant_month_inca string
    grant_max_nrnodes int
}

pub struct CloudBox {
pub mut:
    amount          int
    description     string
    storage_gb      f64
    passmark        int
    vcores          int
    mem_gb          f64
    price_range     []f64 = [0.0, 0.0]
    price_simulation f64
    ssd_nr int
}

pub struct AIBox {
pub mut:
    amount          int
    gpu_brand       string
    gpu_version     string
    description     string
    storage_gb      f64
    passmark        int
    vcores          int
    mem_gb          f64
    mem_gb_gpu      f64
    price_range     []f64 = [0.0, 0.0]
    price_simulation f64
    hdd_nr          int
    ssd_nr          int
}

pub struct StorageBox {
pub mut:
    amount          int
    description     string
    price_range     []f64 = [0.0, 0.0]
    price_simulation f64
}

fn (mut n Node) validate_percentage(v int) ! {
    if v < 0 || v > 100 {
        return error('Value must be between 0 and 100')
    }
}

pub fn preprocess_value(v string) string {
    // Implement the preprocessing logic here
    return v
}

pub fn (mut n Node) preprocess_location(v string) ! {
    n.continent = preprocess_value(v)
    n.country = preprocess_value(v)
}


// pub fn (mut n Node) parse_deliverytime(v string) ! {
//     n.deliverytime = time.parse(v, 'YYYY-MM-DD')!
// }