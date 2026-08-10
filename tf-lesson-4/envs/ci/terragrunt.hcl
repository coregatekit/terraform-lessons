include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/app-storage"
}

inputs = {
  environment = get_env("PR_ENVIRONMENT", "local-test")
  bucket_name = "myapp"
}
