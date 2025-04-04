variable "name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda handler"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "source_path" {
  description = "Path to Lambda .zip file"
  type        = string
}

variable "env_vars" {
  description = "Environment variables for Lambda"
  type        = map(string)
}

variable "timeout" {
  description = "Lambda timeout"
  type        = number
  default     = 5
}
