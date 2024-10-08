# main.tf
provider "aws" {
  region = "us-west-1"  # Change as needed
}

terraform {
  backend "s3" {
    bucket         = "terraform-backend-s3-sample"  # Replace with your S3 bucket name
    key            = "terraform.tfstate"   # The path to the state file within the bucket
    region         = "us-west-1"                      # The AWS region where the bucket is located
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs"
  roles      = [aws_iam_role.lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world" {
  function_name = "HelloWorldFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "com.mthalla.hello.world.lambda.MainFunction::handleRequest"
  runtime       = "java11"  # Choose the runtime as per your Java version
  memory_size   = 128
  timeout       = 10

  # Path to your packaged .jar file
  filename      = "../target/com.mthalla.hello.world.lambda-1.0-SNAPSHOT.jar"  # Update the path
  source_code_hash = filebase64sha256("../target/com.mthalla.hello.world.lambda-1.0-SNAPSHOT.jar")  # Hash to force updates on change
}

resource "null_resource" "invoke_lambda" {
  depends_on = [aws_lambda_function.hello_world]

  provisioner "local-exec" {
    command = <<EOT
      aws lambda invoke --function-name HelloWorldFunction --payload "{}" output.json
      echo Lambda invocation response:
      type output.json
    EOT
  }
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_world.arn
}
