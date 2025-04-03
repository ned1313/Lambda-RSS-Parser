variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-west-2"
}

variable "rss_feed_url" {
  description = "The URL of the RSS feed to be parsed by the Lambda function"
  type        = string
  default     = "https://nedinthecloud.com/blog/index.xml"
}