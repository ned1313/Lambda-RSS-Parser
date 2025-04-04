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

variable "time_span" {
  description = "Time span in hours to filter the RSS feed items"
  type        = number
  default     = 1
  validation {
    condition     = var.time_span > 0
    error_message = "The time span must be a positive number."
  }
}