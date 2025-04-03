terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "lambda_role" {
  name = "rss_parser_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_layer_version" "feedparser_layer" {
  filename            = "./lambda/feedparser.zip"
  layer_name          = "feedparser"
  compatible_runtimes = ["python3.11"]
  description         = "Layer containing feedparser library"
}

resource "aws_lambda_function" "rss_parser" {
  filename      = "./lambda/lambda_function.zip"
  function_name = "rss_parser"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  layers        = [aws_lambda_layer_version.feedparser_layer.arn]

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      RSS_FEED_URL = var.rss_feed_url # Replace with your actual RSS feed URL
      # Add any other environment variables needed for your Lambda function here
    }
  }
}

resource "aws_cloudwatch_event_rule" "hourly" {
  name                = "hourly-trigger"
  description         = "Triggers RSS parser Lambda function every hour"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.hourly.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.rss_parser.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rss_parser.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.hourly.arn
}