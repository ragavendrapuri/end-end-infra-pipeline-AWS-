terraform {
  backend "s3" {
    bucket       = "raghav-devops-tfstate"
    key          = "terraformstates/prod.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}