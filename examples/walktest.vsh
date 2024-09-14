import os

fn main() {
  for _, dirpath, _ in os.walk('.') {
    for _, filename in os.listdir(dirpath) {
      if filename.ends_with('.collections') {
        println('Processing: ${filename}')
        collection_name := get_collection_name(os.join_path(dirpath, filename))
        println('Collection name: ${collection_name}')
        // ... do something with the collection_name
      }
    }
  }
}

fn get_collection_name(filepath string) string {
  mut contents := os.read_file(filepath) or { return os.base(filepath) }
  if contents.len == 0 {
    return os.base(filepath)
  }
  lines := contents.split('\n')
  for _, line in lines {
    if line.trim().starts_with('name:') {
      return line.trim()[5..].trim() // Extract text after "name:"
    }
  }
  return os.base(filepath)
}
