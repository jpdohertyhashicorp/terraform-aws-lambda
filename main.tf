
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_lambda_function" "stocks_resource" {
  filename      = "deployment-package.zip"
  function_name = "stocks_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda-function.lambda_handler"

  runtime = "python3.8"

  environment {
    variables = {
      api_token = var.api_token
    }
  }

}
