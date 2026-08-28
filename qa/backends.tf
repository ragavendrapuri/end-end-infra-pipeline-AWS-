/*
terraform {
  cloud {
    organization = "ORGNAME"

    workspaces {
      name = "qa_tf_resources_ws"
    }
  }
}
*/

terraform {
  backend "s3" {
    bucket = "aws-devops-testbucket"
    key    = "terraformstates/qa.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}