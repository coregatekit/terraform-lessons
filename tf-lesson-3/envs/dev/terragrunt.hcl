include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/app-storage"
}

inputs = {
  environment = "dev"
  bucket_name = "myapp"
}