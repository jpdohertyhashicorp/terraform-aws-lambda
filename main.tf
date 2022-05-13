terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

module "lambda_function_existing_package_local" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "stocks_function"
  handler       = "lambda-function.lambda_handler"
  runtime       = "python3.8"
  timeout		= 30

  create_package         = false
  local_existing_package = "./deployment-package.zip"

  environment_variables = {
    api_token = var.api_token
  }
}

