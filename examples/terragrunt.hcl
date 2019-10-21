include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/clusterfrak-dynamics/terraform-aws-ecr.git?ref=v1.0.0"
}

locals {
  aws_region  = basename(dirname(get_terragrunt_dir()))
  env         = "production"
  project     = "myproject"
  custom_tags = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))
}

inputs = {

  env     = local.env
  project = local.project

  aws = {
    "region" = local.aws_region
  }

  custom_tags = merge(
    {
      Env = local.env
    },
    local.custom_tags
  )

  registries = [
    "myproject/one",
    "myproject/two",
    "myproject/three"
  ]
}
