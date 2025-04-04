output "api_url" {
  value = "https://${aws_api_gateway_domain_name.custom.domain_name}"
}
