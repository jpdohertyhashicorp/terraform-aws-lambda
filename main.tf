terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.87.0"
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

module "lambda_function_existing_package_local" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "stocks_function_name"
  handler       = "lambda-function.lambda_handler"
  runtime       = "python3.8"
  timeout		= 30

  create_package         = false
  local_existing_package = "./deployment-package.zip"

  environment_variables = {
    api_token = var.api_token
  }
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}
