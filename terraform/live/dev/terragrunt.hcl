remote_state {

  backend = "s3"

    config = {
        bucket         = "kg-dev-tfstate"
        key            = "${path_relative_to_include()}/terraform.tfstate"
        region         = "eu-west-1"
        encrypt        = true
        dynamodb_table = "kg-dev-tfstate"

        s3_bucket_tags = {
          name  = "Terraform state storage"
        }

        dynamodb_table_tags = {
          name  = "Terraform lock table"
        }
    }
}

//inputs = {
//  default_region               = "eu-west-1"
//}

