# main.tf
provider "aws" {
  region = "us-east-1"  # Change as needed
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
  handler       = "com.mthalla.hello.world.MainFunction::handleRequest"
  runtime       = "java11"  # Choose the runtime as per your Java version
  memory_size   = 128
  timeout       = 10

  # Path to your packaged .jar file
  filename      = "target/com.mthalla.hello.world.lambda-1.0-SNAPSHOT.jar"  # Update the path
  source_code_hash = filebase64sha256("target/com.mthalla.hello.world.lambda-1.0-SNAPSHOT.jar")  # Hash to force updates on change
}


resource "null_resource" "invoke_lambda" {
  depends_on = [aws_lambda_function.hello_world]  # Ensure this runs after Lambda is created

  provisioner "local-exec" {
    command = <<EOT
      aws lambda invoke \
        --function-name ${aws_lambda_function.hello_world.function_name} \
        --payload '{}' \
        output.json
      echo "Lambda invocation response:"
      cat output.json
    EOT
  }
}


output "lambda_function_arn" {
  value = aws_lambda_function.hello_world.arn
}
