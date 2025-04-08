output "api_url" {
  value = "https://${aws_api_gateway_domain_name.custom.domain_name}"
}

output "api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "regional_domain_name" {
  value = aws_api_gateway_domain_name.custom.regional_domain_name
}

output "regional_zone_id" {
  value = aws_api_gateway_domain_name.custom.regional_zone_id
}

