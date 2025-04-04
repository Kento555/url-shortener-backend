variable "name" {
  description = "Prefix name for the alarms and topic"
  type        = string
}

variable "lambda_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}
