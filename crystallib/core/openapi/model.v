module openapi

pub struct Openapi {
pub mut:
    openapi  string
    info     Info
    servers  []Server
    paths    map[string]PathItem
    components Components
}

pub struct Info {
pub mut:
    version  string
    title    string
    license  License
}

pub struct License {
pub mut:
    name     string
}

pub struct Server {
pub mut:
    url      string
}

pub struct PathItem {
pub mut:
    get      Operation [json: "get"]
    post     Operation [json: "post"]
}

pub struct Operation {
pub mut:
    summary      string
    operation_id string [json: "operationId"]
    tags         []string
    parameters   []Parameter
    responses    map[string]Response
}

pub struct Parameter {
pub mut:
    name         string
    in_           string [json: "in"]
    description  string
    required     bool
    schema       Schema
}

pub struct Response {
pub mut:
    description  string
    headers      map[string]Header
    content      map[string]Content
}

pub struct Header {
pub mut:
    description  string
    schema       Schema
}

pub struct Content {
pub mut:
    schema       SchemaRef
}

pub struct SchemaRef {
pub mut:
    ref          string
}

pub struct Schema {
pub mut:
    type_         string [json: "type"]
    maximum      int [json: "maximum"]
    format       string
}

pub struct Components {
pub mut:
    schemas      map[string]SchemaObject
}

pub struct SchemaObject {
pub mut:
    type_         string [json: "type"]
    required     []string
    properties   map[string]Property
    items        SchemaRef
    max_items    int [json: "maxItems"]
}

pub struct Property {
pub mut:
    type_        string [json: "type"]
    format       string
}


