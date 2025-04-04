variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "env" {
  description = "Environment (e.g., dev, prod)"
  type        = string
}
