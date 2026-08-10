include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/app-storage"
}

inputs = {
  environment = "prod"
  bucket_name = "myapp"
}