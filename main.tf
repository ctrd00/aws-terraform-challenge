terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "sys_pass" {
  sensitive = true
}

# ECR

resource "aws_ecr_repository" "app" {
  name         = "merapar-challenge"
  force_delete = true
}

# IAM
# Role to allow App Runner to pull the image from ECR
resource "aws_iam_role" "apprunner_ecr" {
  name = "merapar-challenge-apprunner-ecr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "apprunner_ecr" {
  role       = aws_iam_role.apprunner_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# Allows the running app to access SSM
resource "aws_iam_role" "instance" {
  name = "merapar-challenge-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "instance_ssm" {
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:PutParameter"]
      Resource = "arn:aws:ssm:*:*:parameter/dynamic_string"
    }]
  })
}

# SSM Dynamic Sring Parameter

resource "aws_ssm_parameter" "dynamic_string" {
  name  = "dynamic_string"
  type  = "String"
  value = "default_value"

  lifecycle {
    ignore_changes = [value]
  }
}

# App Runner

resource "aws_apprunner_service" "app" {
  service_name = "merapar-challenge"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.app.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "5000"
        runtime_environment_variables = {
          SYS_PASS = var.sys_pass
        }
      }
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.instance.arn
    cpu               = "256"
    memory            = "512"
  }

  health_check_configuration {
    protocol = "HTTP"
    path     = "/hello"
  }
}

output "app_url" {
  value = "https://${aws_apprunner_service.app.service_url}"
}
