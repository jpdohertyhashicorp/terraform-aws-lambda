
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61.0"
    }
	azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

// resource "aws_iam_role" "iam_for_lambda" {
//   name = "iam_for_lambda"

//   assume_role_policy = jsonencode({
//     Version = "2012-10-17"
//     Statement = [{
//       Action = "sts:AssumeRole"
//       Effect = "Allow"
//       Sid    = ""
//       Principal = {
//         Service = "lambda.amazonaws.com"
//       }
//       }
//     ]
//   })
// }

// resource "aws_lambda_function" "stocks_resource" {
//   filename      = "deployment-package.zip"
//   function_name = "stocks_function_name"
//   role          = aws_iam_role.iam_for_lambda.arn
//   handler       = "lambda-function.lambda_handler"
//   timeout		= 30
//   runtime = "python3.8"

//   environment {
//     variables = {
//       api_token = var.api_token
//     }
//   }

// }

module "lambda_function_existing_package_local" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "stocks_function_name"
  handler       = "lambda-function.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = "./deployment-package.zip"

  environment_variables = {
    api_token = var.api_token
  }
}

module "sql-database" {
  source              = "Azure/database/azurerm"
  resource_group_name = "my-rg"
  location            = "eastus"
  db_name             = "example-database"
  sql_admin_username  = "admin"
  sql_password        = var.azure_sql_password

  tags= {
    environment = "dev"
  }             

}
