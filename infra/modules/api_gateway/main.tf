resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = "API Gateway for URL Shortener"
}

resource "aws_api_gateway_resource" "newurl" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "newurl"
}

resource "aws_api_gateway_resource" "shortid" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{shortid}"
}

# POST /newurl
resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.newurl.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.newurl.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_post_invoke_arn
}

# GET /{shortid}
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.shortid.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.shortid" = true
  }
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.shortid.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_get_invoke_arn
  request_templates = {
    "application/json" = <<EOF
{
  "short_id": "$input.params('shortid')"
}
EOF
  }
}

resource "aws_api_gateway_method_response" "get_302" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.shortid.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "302"
  response_parameters = {
    "method.response.header.Location" = true
  }
}

resource "aws_api_gateway_integration_response" "get_302" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.shortid.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = aws_api_gateway_method_response.get_302.status_code
  response_parameters = {
    "method.response.header.Location" = "integration.response.body.location"
  }
}

resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.post,
    aws_api_gateway_integration.get
  ]
  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "v1"

  xray_tracing_enabled = true
}



# resource "aws_api_gateway_domain_name" "custom" {
#   domain_name              = var.custom_domain
#   regional_certificate_arn = acm.certificate.this
#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

resource "aws_api_gateway_domain_name" "custom" {
  domain_name              = var.custom_domain
  regional_certificate_arn = var.cert_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  security_policy = "TLS_1_2"

  depends_on = [aws_api_gateway_stage.this]

}


resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.custom.domain_name
}


